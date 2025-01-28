import 'package:collection/collection.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/concepts/balance_address.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/wallet/extended_wallet_base.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/domain/storage/secure.dart';
import 'package:wallet_utils/wallet_utils.dart';
import 'package:magic/services/services.dart';
import 'package:magic/cubits/fade/cubit.dart';
import 'package:magic/services/satori.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/utils/logger.dart';

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
    List<BalanceAddress>? balanceAddresses,
    String? poolAddress,
    bool? isSubmitting,
    PoolStatus? poolStatus,
    PoolState? prior,
  }) {
    emit(PoolState(
      active: active ?? state.active,
      amount: amount ?? state.amount,
      poolHolding: pooHolding ?? state.poolHolding,
      balanceAddresses: balanceAddresses ?? state.balanceAddresses,
      poolAddress: poolAddress ?? state.poolAddress,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      poolStatus: poolStatus ?? state.poolStatus,
      prior: prior ?? state.withoutPrior,
    ));
  }

  Future<int> getLastIndex({
    required Blockchain blockchain,
    required Exposure exposure,
    DerivationWallet? derivationWallet,
  }) async {
    derivationWallet ??= cubits.keys.master.derivationWallets.last;
    final index = await cubits.receive.getIndex(
      blockchain: blockchain,
      exposure: exposure,
      derivationWallet: derivationWallet,
    );
    return index;
  }

  String getPrivateKeyOf({
    required Blockchain blockchain,
    required Exposure exposure,
    required DerivationWallet derivationWallet,
    required int hdIndex,
  }) {
    return derivationWallet
        .seedWallet(blockchain)
        .subwallet(
          hdIndex: hdIndex,
          exposure: exposure,
        )
        .keyPair
        .toWIF();
  }

  Future<List<String>> findSatoriBalanceWIFs(
    List<String> satoriAddresses,
  ) async {
    List<DerivationWallet> derivationWallets =
        cubits.keys.master.derivationWallets;
    List<String> wifs = [];
    for (var derivationWallet in derivationWallets) {
      for (var seedWallet in derivationWallet.seedWallets.values) {
        for (var subWalletList in List.of(seedWallet.subwallets.values)) {
          for (var subWallet in List.of(subWalletList)) {
            if (satoriAddresses.contains(subWallet.address)) {
              String privateKey = derivationWallet
                  .seedWallet((subWallet as HDWalletIndexed).blockchain)
                  .subwallet(
                    hdIndex: subWallet.hdIndex,
                    exposure: subWallet.exposure,
                  )
                  .keyPair
                  .toWIF();

              wifs.add(privateKey);
            }
          }
        }
      }
    }

    wifs = wifs.toSet().toList();

    logI('Total WIFs found (unique): ${wifs.length}');
    return wifs;
  }

  Future<List<String>> findAllWalletAddresses() async {
    List<DerivationWallet> derivationWallets =
        cubits.keys.master.derivationWallets;
    List<String> allAddresses = [];

    for (var derivationWallet in derivationWallets) {
      for (var seedWallet in derivationWallet.seedWallets.values) {
        if (seedWallet.blockchain == Blockchain.evrmoreMain) {
          for (var subWalletList in List.of(seedWallet.subwallets.values)) {
            for (var subWallet in List.of(subWalletList)) {
              if (subWallet.address != null) {
                allAddresses.add(subWallet.address!);
              }
            }
          }
        }
      }
    }
    allAddresses = allAddresses.toSet().toList();
    logI('Total unique addresses found: ${allAddresses.length}');
    return allAddresses;
  }

  Future<void> joinPool() async {
    try {
      await _fadeOutAndIn();

      // var satoriData = state.balanceAddresses?.firstWhereOrNull(
      //   (element) => element.symbol.toLowerCase() == 'satori',
      // );
      //
      // if (satoriData == null || satoriData.addresses.isEmpty) {
      //   logE('Satori data not found');
      //   update(isSubmitting: false);
      //   return;
      // }

      List<String> satoriAddresses = await findAllWalletAddresses();
      final privateKeys = await findSatoriBalanceWIFs(satoriAddresses);

      if (privateKeys.isEmpty) {
        logE('No WIFs found');
        update(isSubmitting: false);
        return;
      }

      List<KPWallet> kpWallets = privateKeys.map((wif) {
        return KPWallet.fromWIF(wif, Blockchain.evrmoreMain.network);
      }).toList();

      SatoriServerClient satoriClient = SatoriServerClient();

      const int batchSize = 10;
      bool allRegistered = true;

      for (int i = 0; i < kpWallets.length; i += batchSize) {
        final batch = kpWallets.skip(i).take(batchSize).toList();

        bool batchResult = await Future.wait(batch.map((kpWallet) async {
          return await satoriClient.registerWallet(
            kpWallet: kpWallet,
            rewardAddress: satoriAddresses.first,
          );
        })).then((results) => results.every((result) => result));

        if (!batchResult) {
          allRegistered = false;
          break;
        }
      }

      if (!allRegistered) {
        update(isSubmitting: false);
        return;
      }

      final rewardAddress = await satoriClient.getRewardAddresses(
        addresses: [satoriAddresses.first],
      );

      if (rewardAddress.isNotEmpty &&
          rewardAddress.containsValue(satoriAddresses.first)) {
        await secureStorage.write(
          key: SecureStorageKey.poolActive.key(),
          value: 'true',
        );
        Holding satoriHolding = cubits.holding.state.holding;
        if (satoriHolding.sats.value > 0) {
          cubits.pool.update(
            poolStatus: PoolStatus.joined,
            pooHolding: satoriHolding,
          );
        }
        cubits.fade.update(fade: FadeEvent.fadeIn);
        update(isSubmitting: false, poolStatus: PoolStatus.joined);
      } else {
        logE('Failed to join the pool');
        update(isSubmitting: false);
      }
    } catch (e, st) {
      logE('Error during join pool: $e $st');
      update(isSubmitting: false);
    }
  }

  Future<void> leavePool() async {
    try {
      await _fadeOutAndIn();

      //Todo: Implement the logic for leaving the pool

      await secureStorage.write(
        key: SecureStorageKey.poolActive.key(),
        value: 'false',
      );

      update(
        isSubmitting: false,
        pooHolding: Holding.empty(),
        poolStatus: PoolStatus.notJoined,
      );
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

  Future<void> registerAddressOnSatoriTransaction({
    required String address,
  }) async {
    final privateKeys = await findSatoriBalanceWIFs([address]);

    if (privateKeys.isEmpty) {
      logE('No WIFs found');
      return;
    }

    List<KPWallet> kpWallets = privateKeys.map((wif) {
      return KPWallet.fromWIF(wif, Blockchain.evrmoreMain.network);
    }).toList();

    logI('Total KPWallets found: ${kpWallets.length}');

    var satoriData = state.balanceAddresses?.firstWhereOrNull(
      (element) => element.symbol.toLowerCase() == 'satori',
    );

    if (satoriData == null || satoriData.addresses.isEmpty) {
      logE('Satori data not found');
      update(isSubmitting: false);
      return;
    }

    SatoriServerClient satoriClient = SatoriServerClient();

    bool allRegistered = await Future.wait(kpWallets.map((kpWallet) async {
      logI('Registering wallet for kpWallet');
      bool response = await satoriClient.registerWallet(
        kpWallet: kpWallet,
        rewardAddress: satoriData.addresses.first,
      );
      return response;
    })).then((results) => results.every((result) => result));

    if (!allRegistered) {
      return;
    }
  }

  Future<void> _fadeOutAndIn() async {
    cubits.fade.update(fade: FadeEvent.fadeOut);
    await Future.delayed(fadeDuration);
    update(isSubmitting: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
  }
}
