import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/security.dart';
import 'package:magic/domain/server/serverv2_client.dart';
import 'package:magic/domain/server/wrappers/unsigned_tx_result.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/services/calls/server.dart';
import 'package:magic/utils/logger.dart';
import 'package:moontree_utils/moontree_utils.dart';

class UnsignedTransactionCall extends ServerCall {
  late List<DerivationWallet> derivationWallets;
  late List<KeypairWallet> keypairWallets;
  late Blockchain blockchain;
  late String symbol;
  final String changeAddress;
  final String address;
  final int sats;
  final String? memo;
  UnsignedTransactionCall({
    required this.derivationWallets,
    required this.keypairWallets,
    required this.blockchain,
    required this.address,
    required this.sats,
    required this.symbol,
    required this.changeAddress,
    this.memo,
  });

  Future<List<UnsignedTransactionResult>> unsignedTransaction({
    double? feeRatePerByte,
    required Chaindata chain,
    required List<String> roots,
    required List<String> h160s,
    required List<String> addresses,
    required List<String?> serverAssets,
    required List<int> satsToSend,
  }) async =>
      await runCall(() async =>
          await client.unsignedTransaction.generateUnsignedTransaction(
              chainName: chain.name,
              request: UnsignedTransactionRequest(
                myH106s: h160s,
                myPubkeys: roots,
                feeRateKb: 1000001, //minimum 1000000
                // null works for ravencoin but not evrmore,
                // so we always supply the minimum.
                // we can get more sophisticated later.
                //feeRatePerByte == null ? null : feeRatePerByte * 1000,
                changeSource: changeAddress,
                eachOutputAddress: addresses,
                eachOutputAsset: serverAssets,
                eachOutputAmount: satsToSend,
                eachOutputAssetMemo: [for (final _ in addresses) null],
                eachOutputAssetMemoTimestamp: [for (final _ in addresses) null],
                opReturnMemo: memo == "" || memo == null
                    ? null
                    : memo!.utf8ToHex, // should be hex string
              )));

  Future<UnsignedTransactionResultCalled?> call() async {
    final String? serverSymbol = (blockchain.isCoin(symbol) ? null : symbol);
    final roots = derivationWallets
        .map((e) => e.roots(blockchain))
        .expand((e) => e)
        .toList();
    final h160s =
        keypairWallets.map((e) => e.h160AsString(blockchain)).toList();
    final List<UnsignedTransactionResult> unsigned = await unsignedTransaction(
      chain: blockchain.chaindata,
      roots: roots,
      h160s: h160s,
      addresses: [address],
      serverAssets: [serverSymbol],
      satsToSend: [sats],
    );

    if (unsigned.length == 1 && unsigned.first.error != null) {
      logE('error: ${unsigned.first.error}');
      // handle
      return null;
    }

    return translate(unsigned, blockchain, roots, h160s);
  }

  UnsignedTransactionResultCalled translate(
    List<UnsignedTransactionResult> records,
    Blockchain blockchain,
    List<String> roots,
    List<String> h160s,
  ) =>
      UnsignedTransactionResultCalled(
        unsignedTransactionResults: records,
        derivationWallets: derivationWallets,
        keypairWallets: keypairWallets,
        address: address,
        sats: sats,
        security: Security(symbol: symbol, blockchain: blockchain),
        changeAddress: changeAddress,
        memo: memo,
        roots: roots,
        h160s: h160s,
      );
}
