// ignore_for_file: avoid_print

import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show AmountToSatsExtension, evrAirdropTx;
import 'package:electrum_adapter/electrum_adapter.dart';
import 'package:client_back/client_back.dart';

import 'asset.dart';

class HistoryService {
  bool busy = false;
  int calledAllDoneProcess = 0; // used to hide transactions while downloading
  Future<void> aggregatedDownloadProcess(List<Address> addresses) async {
    busy = true;
    final Set<String> txHashes =
        filterOutPreviouslyDownloaded(await getHistories(addresses)).toSet();
    final List<Tx> txs = await grabTransactions(txHashes);
    await saveThese(<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>>[
      for (Tx tx in txs) await parseTx(tx)
    ]);
    busy = false;
  }

  /// never called
  //Future<List<List<String>>> getHistories(List<Address> addresses) async {
  //  try {
  //    var listOfLists = await services.client.api.getHistories(addresses);
  //    return [
  //      for (var x in listOfLists) x.map((history) => history.txHash).toList()
  //    ];
  //  } catch (e) {
  //    try {
  //      var txIds = <List<String>>[];
  //      for (var address in addresses) {
  //        var historiesItem;
  //        try {
  //          historiesItem = (await services.client.api.getHistory(address))
  //              .map((history) => history.txHash)
  //              .toList();
  //        } catch (e) {
  //          historiesItem = [];
  //        }
  //        txIds.add(historiesItem);
  //      }
  //      return txIds;
  //    } catch (e) {
  //      return [for (var _ in addresses) []];
  //    }
  //  }
  //}

  Future<List<String>> getHistories(List<Address> addresses) async {
    try {
      final List<List<ScripthashHistory>> listOfLists =
          await services.client.api.getHistories(addresses);
      return <List<String>>[
        for (List<ScripthashHistory> x in listOfLists)
          x.map((ScripthashHistory history) => history.txHash).toList()
      ].expand((List<String> e) => e).toList();
    } catch (e) {
      try {
        final List<List<String>> txIds = <List<String>>[];
        for (final Address address in addresses) {
          List<String> historiesItem;
          try {
            historiesItem = (await services.client.api.getHistory(address))
                .map((ScripthashHistory history) => history.txHash)
                .toList();
          } catch (e) {
            historiesItem = <String>[];
          }
          txIds.add(historiesItem);
        }
        return txIds.expand((List<String> e) => e).toList();
      } catch (e) {
        return <String>[];
      }
    }
  }

  /// called during address subscription
  Future<List<String>> getHistory(Address address) async {
    try {
      final List<String> t = (await services.client.api.getHistory(address))
          .map((ScripthashHistory history) => history.txHash)
          .toList();
      return t;
    } catch (e) {
      return <String>[];
    }
  }

  Future<void> getAndSaveMempoolTransactions() async {
    final Set<String> x =
        pros.transactions.mempool.map((Transaction t) => t.id).toSet();
    if (x.isNotEmpty) {
      await getAndSaveTransactions(x);
    }
  }

  Future<void> getAndSaveTransactions(
    Set<String> txIds, {
    bool saveVin = true,
    bool saveVout = true,
  }) async =>
      getTransactions(txIds, saveVin: saveVin, saveVout: saveVout);

  Future<void> allDoneProcess() async {
    busy = true;
    calledAllDoneProcess += 1;
    await saveDanglingTransactions();
    busy = false;
  }

  /// don't need this for creating UTXO set anymore but...
  /// still need this for getting correct balances of some transactions...
  /// one more step - get all vins that have no corresponding vout (in the db)
  /// and get the vouts for them
  Future<void> saveDanglingTransactions() async => getTransactions(
      filterOutPreviouslyDownloaded(
          pros.vins.dangling.map((Vin vin) => vin.voutTransactionId).toSet()),
      saveVin: false);

  Iterable<String> filterOutPreviouslyDownloaded(
    Iterable<String> transactionIds,
  ) =>
      transactionIds
          .where((String transactionId) => !pros.transactions.confirmed
              .map((Transaction e) => e.id)
              .contains(transactionId))
          .toSet();

  Iterable<String> filterOutTooLarge(Iterable<String> transactionIds) =>
      transactionIds
          .where((String transactionId) => transactionId != evrAirdropTx)
          .toSet();

  /// we capture securities here. if it's one we've never seen,
  /// get it's metadata and save it in the securities proclaim.
  /// return value and security to be saved in vout.
  Future<Tuple3<int, Security, Asset?>> handleAssetData(
    Tx tx,
    TxVout vout,
    Chain chain,
    Net net,
  ) async {
    String symbol = vout.scriptPubKey.asset ?? 'RVN';
    int value = vout.valueSat;
    Security? security =
        pros.securities.primaryIndex.getOne(symbol, chain, net);
    Asset? asset = pros.assets.primaryIndex.getOne(symbol, chain, net);
    if (security == null ||
        asset == null ||
        vout.scriptPubKey.type == 'reissue_asset') {
      if (<String>['transfer_asset', 'reissue_asset']
          .contains(vout.scriptPubKey.type)) {
        value = vout.scriptPubKey.amount.asSats;
        //if we have no record of it in pros.securities...
        final AssetRetrieved? assetRetrieved =
            await services.download.asset.get(symbol, vout: vout);
        if (assetRetrieved != null) {
          value = assetRetrieved.value;
          asset = assetRetrieved.asset;
          security = assetRetrieved.security;
        }
      } else if (vout.scriptPubKey.type == 'new_asset') {
        symbol = vout.scriptPubKey.asset!;
        value = vout.scriptPubKey.amount.asSats;
        asset = Asset(
          symbol: symbol,
          metadata: vout.scriptPubKey.ipfsHash ?? '',
          satsInCirculation: value,
          divisibility: vout.scriptPubKey.units ?? 0,
          reissuable: vout.scriptPubKey.reissuable == 1,
          transactionId: tx.txid,
          position: vout.n,
          chain: chain,
          net: net,
        );
        security = Security(
          symbol: symbol,
          chain: chain,
          net: net,
        );
        await pros.assets.save(asset);
        await pros.securities.save(security);
        streams.asset.added.add(asset);
      }
    }
    return Tuple3<int, Security, Asset?>(
        value, security ?? pros.securities.currentCoin, asset);
  }

  Future<List<Tx>> grabTransactions(Iterable<String> transactionIds) async {
    busy = true;
    List<Tx> txs = <Tx>[];
    transactionIds = filterOutTooLarge(transactionIds);
    try {
      txs = await services.client.api.getTransactions(transactionIds);
    } catch (e) {
      final List<Future<Tx>> futures = <Future<Tx>>[];
      for (final String transactionId in transactionIds) {
        futures.add(services.client.api.getTransaction(transactionId));
      }
      txs = await Future.wait<Tx>(futures);
    }
    return txs;
  }

  Future<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>> parseTx(Tx tx) async {
    final Set<Vin> newVins = <Vin>{};
    final Set<Vout> newVouts = <Vout>{};
    final Set<Transaction> newTxs = <Transaction>{};
    Chain? chain;
    Net? net;
    Chain safeChain = Chain.none;
    Net safeNet = Net.main;
    for (final TxVout vout in tx.vout) {
      if (vout.scriptPubKey.type == 'nullassetdata') {
        continue;
      }

      /// if addresses had a chain...
      //chain ??= pros.addresses.byAddress
      //    .getOne(vout.scriptPubKey.addresses?[0])
      //    ?.chain;
      //net ??=
      //    pros.addresses.byAddress.getOne(vout.scriptPubKey.addresses?[0])?.net;
      safeChain = chain ?? pros.settings.chain;
      safeNet = net ?? pros.settings.net;
      final Tuple3<int, Security, Asset?> vs =
          await handleAssetData(tx, vout, safeChain, safeNet);
      newVouts.add(Vout(
        //chain: safeChain,
        //net: safeNet,
        transactionId: tx.txid,
        position: vout.n,
        type: vout.scriptPubKey.type,
        lockingScript: vs.item3 != null ? vout.scriptPubKey.hex : null,
        coinValue:
            <String>['RVN', 'EVR'].contains(vs.item2.symbol) ? vs.item1 : 0,
        assetValue: vs.item3 == null ? null : vout.scriptPubKey.amount.asSats,
        assetSecurityId: vs.item2.id,
        memo: vout.memo,
        assetMemo: vout.assetMemo,
        toAddress: vout.scriptPubKey.addresses?[0],
        // multisig - must detect if multisig...
        additionalAddresses: (vout.scriptPubKey.addresses?.length ?? 0) > 1
            ? vout.scriptPubKey.addresses!
                .sublist(1, vout.scriptPubKey.addresses!.length)
            : null,
      ));
      newTxs.add(Transaction(
        //chain: safeChain,
        //net: safeNet,
        id: tx.txid,
        height: tx.height,
        confirmed: (tx.confirmations ?? 0) > 0,
        time: tx.time,
      ));
    }
    for (final TxVin vin in tx.vin) {
      if (vin.txid != null && vin.vout != null) {
        newVins.add(Vin(
          //chain: safeChain,
          //net: safeNet,
          transactionId: tx.txid,
          voutTransactionId: vin.txid!,
          voutPosition: vin.vout!,
        ));
      } else if (vin.coinbase != null && vin.sequence != null) {
        newVins.add(Vin(
          //chain: safeChain,
          //net: safeNet,
          transactionId: tx.txid,
          voutTransactionId: vin.coinbase!,
          voutPosition: vin.sequence!,
          isCoinbase: true,
        ));
      }
    }
    return Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>(
        newTxs, newVins, newVouts);
  }

  Future<void>? getTransactions(
    Iterable<String> transactionIds, {
    bool saveVin = true,
    bool saveVout = true,
  }) async {
    if (transactionIds.isEmpty) {
      return;
    }
    transactionIds = filterOutTooLarge(transactionIds);
    busy = true;
    List<Tx> txs = <Tx>[];
    try {
      /// kinda a hack https://github.com/moontreeapp/moontree/issues/444#issuecomment-1101667621
      if (!saveVin || transactionIds.length > 50) {
        /// for a wallet with any serious amount of transactions getTransactions
        /// will probably error in the event we're getting dangling transactions
        /// (saveVin == false) so in that case go straight to catch clause:
        throw Exception();
      }
      //print('getting transactionIds $transactionIds');
      txs = await services.client.api.getTransactions(transactionIds);
    } catch (e) {
      final List<Future<Tx>> futures = <Future<Tx>>[];
      for (final String transactionId in transactionIds) {
        futures.add(services.client.api.getTransaction(transactionId));
      }
      txs = await Future.wait<Tx>(futures);
    }
    await saveTransactions(
      txs,
      saveVin: saveVin,
      saveVout: saveVout,
    );
    busy = false;
  }

  /// doesn't seem to be used...
  //Future<void>? getTransaction(
  //  String transactionId, {
  //  bool saveVin = true,
  //}) async =>
  //    saveTransaction(await services.client.api.getTransaction(transactionId),
  //        saveVin: saveVin);

  /// when an address status change: make our historic tx data match blockchain
  Future<void> saveTransactions(
    List<Tx> txs, {
    bool saveVin = true,
    bool saveVout = true,
  }) async {
    final List<Future<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>>> futures =
        <Future<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>>>[
      for (Tx tx in txs)
        saveTransaction(
          tx,
          saveVin: saveVin,
          saveVout: saveVout,
          justReturn: true,
        )
    ];
    print('saving Futures ${futures.length}');
    await saveThese(
      await Future.wait<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>>(futures),
    );
  }

  Future<void> saveThese(
    List<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>> threes,
  ) async {
    final Set<Transaction> transactions = <Transaction>{};
    final Set<Vin> vins = <Vin>{};
    final Set<Vout> vouts = <Vout>{};
    for (final Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>> three in threes) {
      transactions.addAll(three.item1);
      vins.addAll(three.item2);
      vouts.addAll(three.item3);
    }
    await pros.transactions.saveAll(transactions);
    await pros.vins.saveAll(vins);
    await pros.vouts.saveAll(vouts);
  }

  Future<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>> saveTransaction(
    Tx tx, {
    bool saveVin = true,
    bool saveVout = true,
    bool justReturn = false,
  }) async {
    final Set<Vin> newVins = <Vin>{};
    final Set<Vout> newVouts = <Vout>{};
    final Set<Transaction> newTxs = <Transaction>{};
    Chain? chain;
    Net? net;
    Chain safeChain = Chain.none;
    Net safeNet = Net.main;
    for (final TxVout vout in tx.vout) {
      if (vout.scriptPubKey.type == 'nullassetdata') {
        continue;
      }

      /// if addresses had a chain...
      //chain ??= pros.addresses.byAddress
      //    .getOne(vout.scriptPubKey.addresses?[0])
      //    ?.chain;
      //net ??=
      //    pros.addresses.byAddress.getOne(vout.scriptPubKey.addresses?[0])?.net;
      safeChain = chain ?? pros.settings.chain;
      safeNet = net ?? pros.settings.net;
      final Tuple3<int, Security, Asset?> vs =
          await handleAssetData(tx, vout, safeChain, safeNet);
      if (saveVout) {
        newVouts.add(Vout(
          //chain: safeChain,
          //net: safeNet,
          transactionId: tx.txid,
          position: vout.n,
          type: vout.scriptPubKey.type,
          lockingScript: vs.item3 != null ? vout.scriptPubKey.hex : null,
          coinValue:
              <String>['RVN', 'EVR'].contains(vs.item2.symbol) ? vs.item1 : 0,
          assetValue: vs.item3 == null ? null : vout.scriptPubKey.amount.asSats,
          assetSecurityId: vs.item2.id,
          memo: vout.memo,
          assetMemo: vout.assetMemo,
          toAddress: vout.scriptPubKey.addresses?[0],
          // multisig - must detect if multisig...
          additionalAddresses: (vout.scriptPubKey.addresses?.length ?? 0) > 1
              ? vout.scriptPubKey.addresses!
                  .sublist(1, vout.scriptPubKey.addresses!.length)
              : null,
        ));
      }
      newTxs.add(Transaction(
        //chain: safeChain,
        //net: safeNet,
        id: tx.txid,
        height: tx.height,
        confirmed: (tx.confirmations ?? 0) > 0,
        time: tx.time,
      ));
    }
    if (saveVin) {
      for (final TxVin vin in tx.vin) {
        if (vin.txid != null && vin.vout != null) {
          newVins.add(Vin(
            //chain: safeChain,
            //net: safeNet,
            transactionId: tx.txid,
            voutTransactionId: vin.txid!,
            voutPosition: vin.vout!,
          ));
        } else if (vin.coinbase != null && vin.sequence != null) {
          newVins.add(Vin(
            //chain: safeChain,
            //net: safeNet,
            transactionId: tx.txid,
            voutTransactionId: vin.coinbase!,
            voutPosition: vin.sequence!,
            isCoinbase: true,
          ));
        }
      }
    }
    if (justReturn) {
      return Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>(
          newTxs, newVins, newVouts);
    } else {
      await pros.transactions.saveAll(newTxs);
      await pros.vins.saveAll(newVins);
      await pros.vouts.saveAll(newVouts);
    }
    return const Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>(
        <Transaction>{}, <Vin>{}, <Vout>{});
  }
}