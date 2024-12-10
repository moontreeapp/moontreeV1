// services/prices.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeFiatValueService {
  static final List<String> validTickers = ['EVR', 'RVN', 'SATORI'];

  static Future<String> getFiatValue(String ticker, double amount) async {
    if (!validTickers.contains(ticker.toUpperCase())) {
      return '0';
    }

    try {
      final price = await ExchangeFiatValueRepo.getFiatValue(ticker);
      final fiatValue = price * amount;
      return fiatValue.toStringAsFixed(2);
    } catch (error) {
      print('Error getting fiat value: $error');
      return '0';
    }
  }
}

class ExchangeFiatValueRepo {
  static const String XEGGEX_BASE_URL =
      'https://api.xeggex.com/api/v2/market/getbysymbol/';
  static const String BINANCE_BASE_URL =
      'https://api.binance.us/api/v3/ticker/price';
  static const String SAFETRADE_BASE_URL =
      'https://safe.trade/api/v2/trade/public/tickers/satoriusdt';

  static Future<double> getFiatValue(String ticker) async {
    try {
      double lastPrice;

      if (ticker.toLowerCase() == 'evr') {
        lastPrice = await getXeggexPrice(ticker);
      } else if (ticker.toLowerCase() == 'rvn') {
        lastPrice = await getBinancePrice(ticker);
      } else if (ticker.toLowerCase() == 'satori') {
        lastPrice = await getSafeTradePrice(ticker);
      } else {
        throw Exception('Unsupported ticker: $ticker');
      }

      print('ExchangeFiatValueRepo $ticker lastPrice: $lastPrice');
      return lastPrice;
    } catch (error) {
      print('Error fetching fiat value: $error');
      return 0;
    }
  }

  static Future<double> getXeggexPrice(String ticker) async {
    final response = await http
        .get(Uri.parse('$XEGGEX_BASE_URL${ticker.toUpperCase()}/USDT'));
    final data = jsonDecode(response.body);
    return parsePrice(data['lastPrice']);
  }

  static Future<double> getBinancePrice(String ticker) async {
    final response = await http
        .get(Uri.parse('$BINANCE_BASE_URL?symbol=${ticker.toUpperCase()}USDT'));
    final data = jsonDecode(response.body);
    return parsePrice(data['price']);
  }

  static Future<double> getSafeTradePrice(String ticker) async {
    final response = await http.get(Uri.parse(SAFETRADE_BASE_URL));
    final data = jsonDecode(response.body);
    return parsePrice(data['last']);
  }

  static double parsePrice(String price) {
    final parsedPrice = double.tryParse(price);
    return parsedPrice ?? 0;
  }
}
