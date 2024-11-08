import 'dart:typed_data';

import 'package:magic/domain/wallet/hex.dart';
import 'package:wallet_utils/wallet_utils.dart';

KPWallet keypairWalletFromPubKey(String pubKeyHex, NetworkType network) {
  Uint8List pubKey = hexToBytesPubkey(pubKeyHex);
  final keyPair = ECPair.fromPublicKey(pubKey, network: network);
  final p2pkh = P2PKH(
      data: PaymentData(pubkey: keyPair.publicKey),
      asset: null,
      assetAmount: null,
      assetLiteral: Uint8List(0),
      network: network);
  return KPWallet(keyPair, p2pkh, network);
}
