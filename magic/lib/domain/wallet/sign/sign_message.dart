import 'dart:convert' show base64Encode, utf8;
import 'dart:typed_data' show ByteData, Uint8List;

import 'package:bip32/src/utils/wif.dart' as wif;
import 'package:crypto/crypto.dart' show sha256;
import 'package:ecdsa/ecdsa.dart' as ecdsa;
import 'package:elliptic/elliptic.dart' show PrivateKey, getSecp256k1;
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:magic/utils/logger.dart';

class SignMessage {
  final String message;
  final String prefix;

  SignMessage({
    required this.message,
    required this.prefix,
  });

  String signCompact({
    required String? privateKeyWIF,
  }) {
    if (privateKeyWIF == null || privateKeyWIF.isEmpty) {
      throw Exception('Private key is required');
    }

    if (kDebugMode) {
      logW('Signing message: $message\nPrivate key: $privateKeyWIF');
    }

    var keyWIF = wif.decode(privateKeyWIF);
    var curve = getSecp256k1();

    var key = PrivateKey.fromBytes(curve, keyWIF.privateKey);

    var sig = ecdsa.signature(key, hash);

    var signature = HEX.decode(sig.toCompactHex());

    int meta = -1;

    // Try all possible meta values to find the correct one
    for (var i in [0, 1, 2, 3]) {
      try {
        logW('Trying meta $i');
        var ethSig = ecdsa.EthSignature.fromRSV(sig.R, sig.S, i);

        var recovered = ecdsa.ecRecover(curve, ethSig, hash);

        if (recovered == key.publicKey) {
          meta = 27 + i;
          break;
        }
      } on Exception catch (e) {
        logW(e);
      }
    }

    if (meta == -1) {
      throw Exception('Failed to sign message');
    } else {
      if (keyWIF.compressed) {
        meta += 4;
      }

      ByteData buffer = ByteData(1);
      buffer.setUint8(0, meta); // Sets single byte
      Uint8List metaBytes = buffer.buffer.asUint8List();

      final result = Uint8List.fromList([...metaBytes, ...signature]);

      String signatureStr = base64Encode(result);
      if (kDebugMode) {
        logW('signatureStr: $signatureStr');
      }

      return signatureStr;
    }
  }

  Uint8List get hash {
    // Convert strings to UTF-8 encoded bytes
    final magicBytes = utf8.encode(prefix);
    final messageBytes = utf8.encode(message);

    // Create a byte buffer to hold the formatted message
    final buffer = ByteData(1 + magicBytes.length + 1 + messageBytes.length);
    var offset = 0;

    // Write magic length and magic
    buffer.setUint8(offset++, magicBytes.length);
    buffer.buffer.asUint8List(offset).setAll(0, magicBytes);
    offset += magicBytes.length;

    // Write message length and message
    buffer.setUint8(offset++, messageBytes.length);
    buffer.buffer.asUint8List(offset).setAll(0, messageBytes);

    // Perform double SHA256
    return Uint8List.fromList(sha256
        .convert(sha256.convert(buffer.buffer.asUint8List()).bytes)
        .bytes);
  }
}
