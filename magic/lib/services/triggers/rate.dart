import 'dart:async';

import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/currency.dart' as currency;
import 'package:magic/domain/concepts/money/security.dart';
import 'package:magic/services/rate.dart';
import 'package:magic/domain/concepts/money/rate.dart';
import 'package:magic/services/services.dart';
import 'package:magic/utils/logger.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class RateWaiter extends Trigger {
  final Grabber evrGrabber;
  final Grabber rvnGrabber;
  final Grabber satoriGrabber;
  // eventually (once swaps matter) we should push this to the device rather than pull every 10 minutes
  static const Duration _rateWait = Duration(minutes: 10);
  Rate? rvnUsdRate;
  Rate? evrUsdRate;
  Rate? satoriUsdRate;

  RateWaiter(
      {required this.evrGrabber,
      required this.rvnGrabber,
      required this.satoriGrabber});

  void init() {
    void saveRates() {
      _saveRate(evrGrabber);
      _saveRate(rvnGrabber);
      _saveRate(satoriGrabber);
    }

    saveRates();
    when(
      thereIsA: Stream<dynamic>.periodic(_rateWait),
      doThis: (_) async => saveRates(),
    );
  }

  Future<void> _saveRate(Grabber rateGrabber) async =>
      _save(rateGrabber: rateGrabber, rate: await _rate(rateGrabber));

  Future<double?> _getExistingRate(Grabber rateGrabber) async {
    Future<double?> fromCache() async => double.tryParse(await storage.read(
            key: StorageKey.rate
                .key(_toRate(rateGrabber: rateGrabber, rate: 0)!.id)) ??
        '');

    switch (rateGrabber.symbol) {
      case 'EVR':
        return evrUsdRate?.rate ?? (await fromCache());
      case 'RVN':
        return rvnUsdRate?.rate ?? (await fromCache());
      case 'SATORI':
        return satoriUsdRate?.rate ?? (await fromCache());
      default:
        return null;
    }
  }

  Future<double> _rate(Grabber rateGrabber) async {
    try {
      return (await rateGrabber.get()) ??
          await _getExistingRate(rateGrabber) ??
          0;
    } catch (e) {
      logE('unable to grab rates');
      return 0;
    }
  }

  Future<double?> getRateOf(String symbol) async {
    if (symbol == 'EVR') {
      return await _rate(evrGrabber);
    }
    if (symbol == 'RVN') {
      return await _rate(rvnGrabber);
    }
    if (symbol == 'SATORI') {
      return await _rate(satoriGrabber);
    }
    return null;
  }

  Rate? _toRate({required Grabber rateGrabber, required double rate}) {
    switch (rateGrabber.symbol) {
      case 'EVR':
        return Rate(
          rate: rate,
          quote: currency.Currency.usd,
          base: Security(
            symbol: rateGrabber.symbol,
            blockchain: Blockchain.evrmoreMain,
          ),
        );
      case 'RVN':
        return Rate(
          rate: rate,
          quote: currency.Currency.usd,
          base: Security(
            symbol: rateGrabber.symbol,
            blockchain: Blockchain.ravencoinMain,
          ),
        );
      case 'SATORI':
        return Rate(
          rate: rate,
          quote: currency.Currency.usd,
          base: Security(
            symbol: rateGrabber.symbol,
            blockchain: Blockchain.evrmoreMain,
          ),
        );
      default:
        return null;
    }
  }

  void _save({required Grabber rateGrabber, required double rate}) {
    logD('saving ${rateGrabber.symbol}, rate: $rate');
    switch (rateGrabber.symbol) {
      case 'EVR':
        evrUsdRate = _toRate(rateGrabber: rateGrabber, rate: rate);
        cubits.wallet.newRate(rate: evrUsdRate!);
        return;
      case 'RVN':
        rvnUsdRate = _toRate(rateGrabber: rateGrabber, rate: rate);
        cubits.wallet.newRate(rate: rvnUsdRate!);
        return;
      case 'SATORI':
        satoriUsdRate = _toRate(rateGrabber: rateGrabber, rate: rate);
        cubits.wallet.newRate(rate: satoriUsdRate!);
        return;
      default:
        return;
    }
  }
}
