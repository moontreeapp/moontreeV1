import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet_utils/wallet_utils.dart';

extension HDWalletAuthPayload on HDWallet {
  Map<String, String> authPayload({String? challenge}) {
    final String message =
        challenge ?? (DateTime.now().millisecondsSinceEpoch / 1000).toString();
    final String signature = base64Encode(sign(message));
    return {
      'address': address!,
      'signature': signature,
      'timestamp': message,
    };
  }
}

class SatoriServerClient {
  final String url;
  double lastCheckin = 0;

  SatoriServerClient({
    String? url,
  }) : url = url ?? 'https://stage.satorinet.io';

  String _getChallenge() => DateTime.now().millisecondsSinceEpoch.toString();

  // registerWallet(hdWallet: cubits.keys.master.derivationWallets.firstWhere(
  //         (DerivationWallet wallet) => wallet
  //             .roots(state.unsignedTransaction!.security.blockchain)
  //             .contains(walletRoot),
  //         orElse: () =>
  //             throw Exception('Wallet not found for root: $walletRoot'))
  //         .seedWallet(state.unsignedTransaction!.security.blockchain)
  //         .subwallet(
  //           hdIndex: derivationIndex,
  //           exposure: exposure,
  //         )
  //         .keyPair;

  //(cubits.keys.master.derivationWallets
  //    .expand((m) => m.seedWallets.values.expand((s) => s.subwallets.values
  //        .expand((subList) => subList.map((sub) => sub.address ?? ''))))
  //    .toSet());

  Future<Map<String, dynamic>> registerWallet({
    required HDWallet hdWallet,
    String? referrer,
  }) async {
    final String challenge = _getChallenge();
    try {
      final http.Response response =
          await http.post(Uri.parse('$url/register/wallet'),
              headers: <String, String>{
                ...hdWallet.authPayload(challenge: challenge),
                if (referrer != null) 'referrer': referrer
              },
              body: jsonEncode({
                "vaultpubkey": hdWallet.pubKey,
                "vaultaddress": hdWallet.address!,
                //"ethaddress": we should derive an eth address from the wallet private key,
                "rewardaddress": hdWallet.address!,
                //"alias": ''
              }));
      if (response.statusCode >= 400) {
        print('Unable to checkin: ${response.body}');
        return {'ERROR': response.body};
      }
      lastCheckin = DateTime.now().millisecondsSinceEpoch / 1000;
      return jsonDecode(response.body);
    } catch (e) {
      print('Error during checkin: $e');
      return {'ERROR': e.toString()};
    }
  }
}
