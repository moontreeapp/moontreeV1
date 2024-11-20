import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet_utils/wallet_utils.dart';
import '../utils/logger.dart';

extension HDWalletAuthPayload on HDWallet {
  Map<String, String> authPayload({String? challenge}) {
    final String message =
        challenge ?? (DateTime.now().millisecondsSinceEpoch / 1000).toString();
    final String signature = base64Encode(sign(message));
    return {
      'message': message,
      'address': address!,
      'pubkey': pubKey,
      'signature': signature,
    };
  }
}

//registerWallet(hdWallet: cubits.keys.master.derivationWallets.last.seedWallet(Blockchain.evrmore).externals.last)
class SatoriServerClient {
  final String url;
  double lastCheckin = 0;

  SatoriServerClient({this.url = 'https://stage.satorinet.io'});

  String _getChallenge() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<Map<String, dynamic>> registerWallet({
    required HDWallet hdWallet,
  }) async {
    final String challenge = _getChallenge();
    try {
      final http.Response response =
          await http.post(Uri.parse('$url/register/wallet'),
              headers: <String, String>{
                ...hdWallet.authPayload(challenge: challenge),
                //'referrer': 'TODO: hard code this'
              },
              body: jsonEncode({
                "vaultpubkey": hdWallet.pubKey,
                "vaultaddress": hdWallet.address!,
                //"ethaddress": we should derive an eth address from the wallet private key,
                "rewardaddress": hdWallet.address!,
                //"alias": ''
              }));
      if (response.statusCode >= 400) {
        logE('Unable to checkin: ${response.body}');
        return {'ERROR': response.body};
      }
      lastCheckin = DateTime.now().millisecondsSinceEpoch / 1000;
      return jsonDecode(response.body);
    } catch (e, st) {
      logE('Error during checkin: $e $st');
      return {'ERROR': e.toString()};
    }
  }
}
