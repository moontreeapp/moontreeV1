import 'package:bip32/src/utils/wif.dart' as wif;
import 'package:magic/domain/wallet/extended_wallet_base.dart';
import 'package:wallet_utils/wallet_utils.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:magic/utils/logger.dart';

class SatoriServerClient {
  final String url;
  double lastCheckin = 0;

  SatoriServerClient({this.url = 'https://stage.satorinet.io'});

  String convertWIFToHex(String wifKey) {
    final decoded = wif.decode(wifKey);
    return bytesToHex(decoded.privateKey);
  }

  Future<bool> registerWallet({
    required KPWallet kpWallet,
    required String rewardAddress,
  }) async {
    try {
      final String privateKey = kpWallet.wif!;
      final String privateKeyHex = convertWIFToHex(privateKey);
      final EthPrivateKey ethPrivateKey = EthPrivateKey.fromHex(privateKeyHex);

      final EthereumAddress ethAddress = ethPrivateKey.address;
      var body = {
        "vaultpubkey": kpWallet.pubKey,
        "vaultaddress": kpWallet.address,
        "ethaddress": ethAddress.hex,
        "rewardaddress": rewardAddress,
      };

      Map<String, String> headers = kpWallet.authPayload(kpWallet.address!);
      final http.Response response = await http.post(
        Uri.parse('$url/register/wallet'),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode >= 400) {
        logE('Unable to checkin: ${response.body}');
        return false;
      }
      lastCheckin = DateTime.now().toUtc().millisecondsSinceEpoch / 1000;
      return response.body == 'OK';
    } catch (e, st) {
      logE('Error during checkin: $e\n$st');
      return false;
    }
  }

  Future<Map<String, String>> getRewardAddresses({
    required List<String> addresses,
  }) async {
    try {
      final body = {
        'addresses': addresses,
      };
      final response = await http.post(
        Uri.parse('$url/api/v0/addresses/rewardaddresses'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.values.contains("address not found")) {
          logE("One or more addresses were not found: $jsonData");
          return jsonData.map((key, value) => MapEntry(key, value as String));
        }

        return jsonData.map((key, value) => MapEntry(key, value as String));
      } else {
        logE('Error Response: ${response.body}');
        return {};
      }
    } catch (e) {
      logE('Exception: $e');
      return {};
    }
  }
}
