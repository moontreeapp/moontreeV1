import 'package:intl/intl.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class ConversionService {
  String rvnUSD(
    double amount, {
    double? rate,
    String prefix = '\$ ',
  }) =>
      amount == 0
          ? NumberFormat('$prefix#,##0.00', 'en_US').format(0)
          : NumberFormat('$prefix#,##0.00', 'en_US')
              .format((amount * (rate ?? services.rate.rvnToUSD ?? 0.0)));

  /// returns a string representation of the value as amount or fiat
  String securityAsReadable(
    int sats, {
    Security? security,
    String? symbol,
    bool asUSD = false,
  }) {
    symbol = getSymbol(symbol: symbol, security: security);
    if (symbol == pros.securities.currentCrypto.symbol) {
      var asAmount = utils.satToAmount(sats);
      return asUSD
          ? rvnUSD(asAmount)
          : NumberFormat('#,##0.########', 'en_US').format(asAmount);
    }
    // asset sats -> asset -> rvn -> usd
    security = getSecurityOf(symbol: symbol, security: security);
    var asset = getAssetOf(symbol: symbol);
    var asAmount = utils.satToAmount(sats);
    return asUSD
        ? rvnUSD(asAmount * (security.toRVNRate))
        : NumberFormat(
                '#,##0${(asset?.divisibility ?? 0) > 0 ? '.' + '#' * (asset?.divisibility ?? 0) : ''}',
                'en_US')
            .format(asAmount);
  }

  Security getSecurityOf({
    Security? security,
    String? symbol,
  }) {
    symbol = getSymbol(symbol: symbol, security: security);
    if (symbol == pros.securities.currentCrypto.symbol) {
      return pros.securities.currentCrypto;
    }
    if (symbol == 'USD') {
      return pros.securities.USD;
    }
    return security ??
        pros.securities.primaryIndex.getOne(symbol, SecurityType.asset,
            pros.settings.chain, pros.settings.net) ??
        Security(
            symbol: symbol,
            securityType: SecurityType.asset,
            chain: pros.settings.chain,
            net: pros.settings.net);
  }

  Asset? getAssetOf({
    Security? security,
    String? symbol,
  }) {
    symbol = getSymbol(symbol: symbol, security: security);
    if (symbol == pros.securities.currentCrypto.symbol) {
      return null;
    }
    security = security ??
        pros.securities.primaryIndex.getOne(symbol, SecurityType.asset,
            pros.settings.chain, pros.settings.net) ??
        Security(
            symbol: symbol,
            securityType: SecurityType.asset,
            chain: pros.settings.chain,
            net: pros.settings.net);
    return pros.assets.primaryIndex
        .getOne(symbol, security.chain, security.net);
  }

  String getSymbol({
    Security? security,
    String? symbol,
  }) {
    security ??
        symbol ??
        (() => throw OneOfMultipleMissing(
            'security or symbol required to identify record.'))();
    return security?.symbol ?? symbol ?? pros.securities.currentCrypto.symbol;
  }
}