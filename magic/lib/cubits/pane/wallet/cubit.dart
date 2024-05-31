import 'dart:math';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/rate.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/concepts/storage.dart';
import 'package:magic/domain/utils/extensions/list.dart';
import 'package:magic/presentation/utils/range.dart';
import 'package:magic/services/calls/holdings.dart';
import 'package:magic/services/services.dart';

part 'state.dart';

class WalletCubit extends UpdatableCubit<WalletState> {
  WalletCubit() : super(const WalletState());
  @override
  String get key => 'walletFeed';
  @override
  void reset() => emit(const WalletState());
  @override
  void setState(WalletState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void refresh() {
    if (state.active) {
      update(active: false);
    }
    update(active: true);
  }

  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);

  @override
  void update({
    bool? active,
    List<Holding>? holdings,
    Widget? child,
    bool? isSubmitting,
  }) {
    emit(WalletState(
      active: active ?? state.active,
      holdings: holdings ?? state.holdings,
      child: child ?? state.child,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  void clearAssets() {
    update(active: false);
    update(holdings: [], active: true);
  }

  Future<bool> populateAssets() async {
    // remember to order by currency first, amount second, alphabetical third
    update(isSubmitting: true);
    final holdings = _sort(_newRateThese(
            symbol: 'EVR',
            rate: await rates.getRateOf('EVR'),
            holdings: await HoldingBalancesCall(
              blockchain: Blockchain.evrmoreMain,
              mnemonicWallets: cubits.keys.master.mnemonicWallets,
              keypairWallets: cubits.keys.master.keypairWallets,
            ).call()) +
        _newRateThese(
            symbol: 'RVN',
            rate: await rates.getRateOf('RVN'),
            holdings: await HoldingBalancesCall(
              blockchain: Blockchain.ravencoinMain,
              mnemonicWallets: cubits.keys.master.mnemonicWallets,
              keypairWallets: cubits.keys.master.keypairWallets,
            ).call()));
    update(holdings: holdings, isSubmitting: false);
    if (rates.rvnUsdRate != null) {
      cacheRate(rates.rvnUsdRate!);
    }
    if (rates.evrUsdRate != null) {
      cacheRate(rates.evrUsdRate!);
    }
    return true;
  }

  void populateAssetsSpoof() {
    // remember to order by currency first, amount second, alphabetical third
    update(holdings: [
      for (final index in range(47))
        Holding(
          name: 'Ravencoin',
          symbol: 'RVN',
          root: 'RVN',
          sats: Sats(pow(index, index ~/ 4.2) as int),
          metadata: HoldingMetadata(
            divisibility: Divisibility(8),
            reissuable: false,
            supply: Sats.fromCoin(Coin(coin: 21000000000)),
          ),
        ),
    ]);
    cubits.balance.update(portfolioValue: Fiat(12546.01));
  }

  /// default sort is by currency type, then by amount, then by alphabetical
  List<Holding> _sort(List<Holding> holdings) =>
      holdings.where((e) => e.isRoot).toList() +
      holdings.where((e) => !e.isRoot).toList();

  // todo pagenate list of holdings
  //Holding getNextBatch(List<Holding> batch) {}

  /// update all the holding with the new rate
  void newRate({required Rate rate}) {
    if (state.holdings.isEmpty) return;
    final holdings = _newRateThese(
        symbol: rate.base.symbol, rate: rate.rate, holdings: state.holdings);
    update(holdings: holdings);
    cacheRate(rate, holdings);
  }

  /// update all the holding with the new rate
  List<Holding> _newRateThese(
      {required String symbol, double? rate, required List<Holding> holdings}) {
    if (holdings.isEmpty || rate == null || rate <= 0) {
      return holdings;
    }
    return holdings
        .map((e) => e.symbol == symbol ? e.copyWith(rate: rate) : e)
        .toList();
  }

  void cacheRate(Rate rate, [List<Holding>? holdings]) {
    // save to disk, so we can load it on next app start
    storage.write(
        key: StorageKey.rate.key(rate.id), value: rate.rate.toStringAsFixed(4));
    // update balance
    cubits.balance.update(
        portfolioValue: Fiat((holdings ?? state.holdings)
            .map((e) => e.coin.toFiat(e.rate).value)
            .sumNumbers()));
  }

  Holding? adminOf(Holding holding) =>
      state.holdings.firstWhereOrNull((h) => h.symbol == '${holding.symbol}!');

  Holding? mainOf(Holding holding) => state.holdings
      .firstWhereOrNull((h) => h.symbol == holding.symbol.replaceAll('!', ''));

  MainAdminPair mainAndAdminOf(Holding holding) => MainAdminPair(
        main: holding.isAdmin ? mainOf(holding) : holding,
        admin: holding.isAdmin ? holding : adminOf(holding),
      );
}

class MainAdminPair {
  final Holding? main;
  final Holding? admin;
  const MainAdminPair({required this.main, required this.admin});
  bool get full => main != null && admin != null;
}