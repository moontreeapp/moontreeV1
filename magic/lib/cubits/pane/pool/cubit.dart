import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/concepts/send.dart';
import 'package:magic/domain/server/wrappers/unsigned_tx_result.dart';
import 'package:magic/domain/wallet/extended_wallet_base.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/domain/storage/secure.dart';
import 'package:magic/services/calls/unsigned.dart';
import 'package:wallet_utils/wallet_utils.dart';
import 'package:magic/services/services.dart';
import 'package:magic/cubits/fade/cubit.dart';
import 'package:magic/services/satori.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/utils/logger.dart';
import 'dart:convert';

part 'state.dart';

class PoolCubit extends UpdatableCubit<PoolState> {
  PoolCubit() : super(const PoolState());
  double height = 0;

  @override
  String get key => 'pool';

  @override
  void reset() => emit(const PoolState());

  @override
  void setState(PoolState state) => emit(state);

  @override
  void hide() => update(active: false);

  @override
  void refresh() {
    update(isSubmitting: false);
    update(isSubmitting: true);
  }

  @override
  void activate() => update(active: true);

  @override
  void deactivate() => update(active: false);

  @override
  void update({
    bool? active,
    String? amount,
    String? poolAddress,
    bool? isSubmitting,
    PoolStatus? poolStatus,
    PoolState? prior,
  }) {
    emit(PoolState(
      active: active ?? state.active,
      amount: amount ?? state.amount,
      poolAddress: poolAddress ?? state.poolAddress,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      poolStatus: poolStatus ?? state.poolStatus,
      prior: prior ?? state.withoutPrior,
    ));
  }

  Future<void> joinPool({required String amount}) async {
    try {
      cubits.fade.update(fade: FadeEvent.fadeOut);
      await Future.delayed(fadeDuration);
      update(isSubmitting: true);
      cubits.fade.update(fade: FadeEvent.fadeIn);

      final privateKey = cubits.keys.master.derivationWallets.last
          .seedWallet(Blockchain.evrmoreMain)
          .subwallet(
            hdIndex: 1,
            exposure: Exposure.external,
          )
          .keyPair
          .toWIF();

      KPWallet kpWallet = KPWallet.fromWIF(
        privateKey,
        Blockchain.evrmoreMain.network,
      );

      var nextAddress = cubits.keys.master.derivationWallets.first
          .seedWallet(Blockchain.evrmoreMain)
          .externals
          .lastOrNull
          ?.address;
      SatoriServerClient satori = SatoriServerClient();
      var response = await satori.registerWallet(
        kpWallet: kpWallet,
      );
      if (response == false) {
        update(isSubmitting: false);
        return;
      }

      var satoriMagicPoolString =
          await secureStorage.read(key: SecureStorageKey.satoriMagicPool.key());
      var satoriMagicPool =
          satoriMagicPoolString != null && satoriMagicPoolString.isNotEmpty
              ? jsonDecode(satoriMagicPoolString)
              : null;
      logWTF(satoriMagicPool);
      if (satoriMagicPool == null ||
          satoriMagicPool['satori_magic_pool'] == null) {
        await secureStorage.write(
          key: SecureStorageKey.satoriMagicPool.key(),
          value: jsonEncode({
            "satori_magic_pool": kpWallet.wif,
            "address": nextAddress,
          }),
        );
      }
      update(
        amount: amount,
        poolAddress: nextAddress,
      );
      await prepareForSend(poolWif: kpWallet.wif);
      cubits.fade.update(fade: FadeEvent.fadeIn);
    } catch (e, st) {
      logE('$e $st');
      update(isSubmitting: false);
    }
  }

  Future<void> sendAmount({bool isLeavingPool = false}) async {
    cubits.toast.suppress = true;
    await cubits.send.broadcast(
      amount: Sats(cubits.send.state.estimate!.amount).toCoin().humanString(),
      symbol: cubits.holding.state.holding.symbol,
    );
    logD(cubits.send.state.txHashes);
    cubits.send.reset();
    await cubits.wallet.populateAssets();
    await Future.delayed(const Duration(seconds: 1));
    cubits.holding.update(active: false);
    await maestro.activateHistory(
      holding: cubits.wallet.state.holdings.firstWhere((holding) =>
          holding.blockchain == cubits.holding.state.holding.blockchain &&
          holding.symbol == cubits.holding.state.holding.symbol),
    );
    await Future.delayed(const Duration(seconds: 1));
    update(
      isSubmitting: false,
      poolStatus: isLeavingPool ? PoolStatus.notJoined : PoolStatus.joined,
    );
    cubits.toast.suppress = false;
  }

  Future<void> prepareForSend({
    bool isLeavingPool = false,
    String? poolWif,
  }) async {
    try {
      final sendSats =
          Coin.fromString(state.amount.replaceAll(',', '')).toSats().value;
      final sendAll = sendSats == cubits.holding.state.holding.sats.value &&
          cubits.holding.state.holding.isCurrency;
      cubits.send.update(
          sendRequest: SendRequest(
        sendAll: sendAll,
        sendAddress: state.poolAddress,
        holding: cubits.holding.state.holding.coin.toDouble(),
        visibleAmount: state.amount,
        sendAmountAsSats: sendSats,
        feeRate: cheapFee,
      ));

      if (isLeavingPool) {
        await setPoolExitTransaction(
          symbol: cubits.holding.state.holding.symbol,
          blockchain: cubits.holding.state.holding.blockchain,
          poolWif: poolWif ?? '',
        );
      } else {
        await cubits.send.setUnsignedTransaction(
          sendAllCoinFlag: sendAll,
          symbol: cubits.holding.state.holding.symbol,
          blockchain: cubits.holding.state.holding.blockchain,
        );
      }
      await cubits.send.signUnsignedTransaction();
      final validateMsg = await cubits.send.verifyTransaction();
      logD(validateMsg);
      if (!validateMsg.item1) {
        cubits.send.update(
            signedTransactions: [],
            txHashes: [],
            removeUnsignedTransaction: true,
            removeEstimate: true);
        cubits.toast.flash(
            msg: const ToastMessage(
          title: 'Error',
          text: 'Unable to generate transaction',
        ));
        update(isSubmitting: false);
      } else {
        await sendAmount(isLeavingPool: isLeavingPool);
      }
    } catch (e, st) {
      update(isSubmitting: false);
      logE('$e $st');
    }
  }

  Future<void> addMoreToPool({required String amount}) async {
    cubits.fade.update(fade: FadeEvent.fadeOut);
    await Future.delayed(fadeDuration);
    update(isSubmitting: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);

    var storedDataString =
        await secureStorage.read(key: SecureStorageKey.satoriMagicPool.key());
    var storedData = jsonDecode(storedDataString ?? '');
    var toAddress = cubits.keys.master.derivationWallets.first
        .seedWallet(Blockchain.evrmoreMain)
        .externals
        .lastOrNull
        ?.address;

    if (storedData == null ||
        !storedData.containsKey('address') ||
        !storedData.containsKey('satori_magic_pool') ||
        toAddress == null) {
      logE('Stored data is incomplete or missing');

      update(isSubmitting: false);
      return;
    }
    update(
      amount: amount,
      poolAddress: toAddress,
    );
    await prepareForSend();
    update(isSubmitting: false);
    cubits.fade.update(fade: FadeEvent.fadeIn);
  }

  Future<void> leavePool() async {
    try {
      cubits.fade.update(fade: FadeEvent.fadeOut);
      await Future.delayed(fadeDuration);
      update(isSubmitting: true);
      cubits.fade.update(fade: FadeEvent.fadeIn);

      var storedDataString =
          await secureStorage.read(key: SecureStorageKey.satoriMagicPool.key());
      var storedData = jsonDecode(storedDataString ?? '');
      var toAddress = cubits.keys.master.derivationWallets.first
          .seedWallet(Blockchain.evrmoreMain)
          .externals
          .lastOrNull
          ?.address;

      if (storedData == null ||
          !storedData.containsKey('address') ||
          !storedData.containsKey('satori_magic_pool') ||
          toAddress == null) {
        logE('Stored data is incomplete or missing');
        update(isSubmitting: false);
        return;
      }

      String fromAddress = storedData['address'];
      String privateKey = storedData['satori_magic_pool'];

      await prepareToSendBack(
        fromAddress: fromAddress,
        privateKey: privateKey,
        toAddress: toAddress,
        amount: state.amount,
      );

      update(isSubmitting: false);
      cubits.fade.update(fade: FadeEvent.fadeIn);
    } catch (e, st) {
      logE('$e $st');
      update(isSubmitting: false);
    }
  }

  Future<void> prepareToSendBack({
    required String fromAddress,
    required String privateKey,
    required String toAddress,
    required String amount,
  }) async {
    SatoriServerClient satori = SatoriServerClient();
    // Todo:Leave pool logic
/*    var response = await satori.leavepool(
      fromAddress,
      privateKey,
      toAddress,
      amount,
    );
    if (response.containsKey('ERROR')) {
      update(isSubmitting: false);
      return;
    } else {
      update(
        amount: amount,
        poolAddress: toAddress,
      );
      await prepareForSend(isLeavingPool: true, poolWif: privateKey);
    }*/
  }

  Future<void> setPoolExitTransaction({
    required Blockchain blockchain,
    required String symbol,
    required String poolWif,
  }) async {
    final changeAddress =
        await cubits.receive.populateChangeAddress(blockchain);

    KeypairWallet(wif: poolWif);
    UnsignedTransactionResultCalled? unsigned = await UnsignedTransactionCall(
      derivationWallets: [],
      keypairWallets: [KeypairWallet(wif: poolWif)],
      symbol: symbol,
      sats: -1,
      changeAddress: changeAddress,
      address: state.poolAddress,
      memo: null,
      blockchain: blockchain,
    ).call();

    cubits.send.update(
      unsignedTransaction: unsigned,
      changeAddress: changeAddress,
    );
  }
}
