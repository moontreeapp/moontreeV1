import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/concepts/send.dart';
import 'package:magic/domain/server/wrappers/unsigned_tx_result.dart';
import 'package:magic/domain/wallet/extended_wallet_base.dart';
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
    Holding? pooHolding,
    String? poolAddress,
    bool? isSubmitting,
    PoolStatus? poolStatus,
    PoolState? prior,
  }) {
    emit(PoolState(
      active: active ?? state.active,
      amount: amount ?? state.amount,
      poolHolding: pooHolding ?? state.poolHolding,
      poolAddress: poolAddress ?? state.poolAddress,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      poolStatus: poolStatus ?? state.poolStatus,
      prior: prior ?? state.withoutPrior,
    ));
  }

  Future<int> _getLastIndex({
    required Blockchain blockchain,
    required Exposure exposure,
  }) async {
    final derivationWallet = cubits.keys.master.derivationWallets.last;
    final index = await cubits.receive.getIndex(
      blockchain: blockchain,
      exposure: exposure,
      derivationWallet: derivationWallet,
    );
    return index;
  }

  Future<void> joinPool({required String amount}) async {
    try {
      await _fadeOutAndIn();
      String? nextAddress;
      String wif;

      var storedDataString =
          await secureStorage.read(key: SecureStorageKey.satoriMagicPool.key());
      var storedData = jsonDecode(storedDataString ?? '{}');

      if (storedData == null ||
          !storedData.containsKey('address') ||
          !storedData.containsKey('satori_magic_pool')) {
        final lastIndex = await _getLastIndex(
          blockchain: Blockchain.evrmoreMain,
          exposure: Exposure.external,
        );

        final privateKey = cubits.keys.master.derivationWallets.last
            .seedWallet(Blockchain.evrmoreMain)
            .subwallet(
              hdIndex: lastIndex,
              exposure: Exposure.external,
            )
            .keyPair
            .toWIF();

        KPWallet kpWallet = KPWallet.fromWIF(
          privateKey,
          Blockchain.evrmoreMain.network,
        );

        wif = kpWallet.wif!;
        nextAddress = kpWallet.address;

        SatoriServerClient satori = SatoriServerClient();

        var response = await satori.registerWallet(
          kpWallet: kpWallet,
        );

        if (response == false) {
          update(isSubmitting: false);
          return;
        }

        var satoriMagicPoolString = await secureStorage.read(
            key: SecureStorageKey.satoriMagicPool.key());
        var satoriMagicPool =
            satoriMagicPoolString != null && satoriMagicPoolString.isNotEmpty
                ? jsonDecode(satoriMagicPoolString)
                : null;
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
      } else {
        nextAddress = storedData['address'];
        wif = storedData['satori_magic_pool'];
      }
      update(
        amount: amount,
        poolAddress: nextAddress,
      );
      await prepareForSend(poolWif: wif);
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
    cubits.send.reset();
    update(
      pooHolding: Holding.empty(),
    );
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
      amount: '',
    );
    update(
      poolStatus: isLeavingPool ? PoolStatus.notJoined : PoolStatus.joined,
    );
    cubits.toast.suppress = false;
  }

  Future<void> prepareForSend({
    bool isLeavingPool = false,
    required String poolWif,
  }) async {
    try {
      final sendSats =
          Coin.fromString(state.amount.replaceAll(',', '')).toSats().value;
      final sendAll = sendSats == cubits.holding.state.holding.sats.value &&
          cubits.holding.state.holding.isCurrency;

      if (isLeavingPool) {
        final leaveSats = Coin.fromString(
                state.poolHolding?.coin.toString().replaceAll(',', '') ?? '0')
            .toSats()
            .value;
        final changeAddress = await cubits.receive
            .populateChangeAddress(cubits.holding.state.holding.blockchain);
        cubits.send.update(
          sendRequest: SendRequest(
            sendAll: true,
            sendAddress: changeAddress,
            holding: state.poolHolding?.coin.toDouble() ?? 0,
            visibleAmount: state.poolHolding?.coin.toString() ?? '',
            sendAmountAsSats: leaveSats,
            feeRate: cheapFee,
          ),
          address: changeAddress,
        );
        await setPoolExitTransaction(
          symbol: cubits.holding.state.holding.symbol,
          blockchain: cubits.holding.state.holding.blockchain,
          poolWif: poolWif,
        );
      } else {
        cubits.send.update(
          sendRequest: SendRequest(
            sendAll: sendAll,
            sendAddress: state.poolAddress,
            holding: cubits.holding.state.holding.coin.toDouble(),
            visibleAmount: state.amount,
            sendAmountAsSats: sendSats,
            feeRate: cheapFee,
          ),
          address: state.poolAddress,
        );
        await cubits.send.setUnsignedTransaction(
          sendAllCoinFlag: sendAll,
          symbol: cubits.holding.state.holding.symbol,
          blockchain: cubits.holding.state.holding.blockchain,
        );
      }
      await cubits.send.signUnsignedTransaction();
      final validateMsg = await cubits.send.verifyTransaction();
      if (!validateMsg.item1) {
        cubits.send.update(
          signedTransactions: [],
          txHashes: [],
          removeUnsignedTransaction: true,
          removeEstimate: true,
        );
        cubits.toast.flash(
          msg: const ToastMessage(
            title: 'Error',
            text: 'Unable to generate transaction',
          ),
        );
        update(isSubmitting: false);
      } else {
        await sendAmount(isLeavingPool: isLeavingPool);
      }
    } catch (e, st) {
      update(isSubmitting: false);
      cubits.toast.flash(
        msg: const ToastMessage(
          title: 'Error',
          text: 'Some error occurred',
        ),
      );
      logE('$e $st');
    }
  }

  Future<void> addMoreToPool({required String amount}) async {
    try {
      await _fadeOutAndIn();

      var storedDataString =
          await secureStorage.read(key: SecureStorageKey.satoriMagicPool.key());
      var storedData = jsonDecode(storedDataString ?? '{}');

      if (storedData == null ||
          !storedData.containsKey('address') ||
          !storedData.containsKey('satori_magic_pool')) {
        logE('Stored data is incomplete or missing');

        update(isSubmitting: false);
        return;
      }
      update(
        amount: amount,
        poolAddress: storedData['address'],
      );
      await prepareForSend(
        poolWif: storedData['satori_magic_pool'],
      );
      update(isSubmitting: false);
      cubits.fade.update(fade: FadeEvent.fadeIn);
    } catch (e) {
      logE(e);
    }
  }

  Future<void> leavePool() async {
    try {
      await _fadeOutAndIn();

      var storedDataString =
          await secureStorage.read(key: SecureStorageKey.satoriMagicPool.key());
      var storedData = jsonDecode(storedDataString ?? '{}');
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

      update(poolAddress: fromAddress);
      await prepareForSend(isLeavingPool: true, poolWif: privateKey);

      update(isSubmitting: false);
      cubits.fade.update(fade: FadeEvent.fadeIn);
    } catch (e, st) {
      logE('$e $st');
      cubits.toast.flash(
        msg: const ToastMessage(
          title: 'Error',
          text: 'Some error occurred',
        ),
      );
      update(isSubmitting: false);
    }
  }

  Future<void> _fadeOutAndIn() async {
    cubits.fade.update(fade: FadeEvent.fadeOut);
    await Future.delayed(fadeDuration);
    update(isSubmitting: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
  }

  Future<void> setPoolExitTransaction({
    required Blockchain blockchain,
    required String symbol,
    required String poolWif,
  }) async {
    final changeAddress =
        await cubits.receive.populateChangeAddress(blockchain);
    UnsignedTransactionResultCalled? unsigned = await UnsignedTransactionCall(
      derivationWallets: cubits.keys.master.derivationWallets,
      keypairWallets: [],
      symbol: symbol,
      sats: cubits.holding.state.holding.sats.value,
      changeAddress: state.poolAddress,
      address: changeAddress,
      memo: null,
      blockchain: blockchain,
    ).call();

    cubits.send.update(
      unsignedTransaction: unsigned,
      changeAddress: state.poolAddress,
    );
  }
}
