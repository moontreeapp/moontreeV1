// standalone signing

import 'dart:convert';
import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:wallet_utils/wallet_utils.dart';

class EvrmoreMessage {
  final Uint8List magic;
  final Uint8List message;

  EvrmoreMessage({
    String message = "",
    String magic = "\x18Evrmore Signed Message:\n",
  })  : message = utf8.encode(message),
        magic = utf8.encode(magic);

  Uint8List serialize() {
    // Combine magic and message with their lengths
    final magicLength = _encodeVarInt(magic.length);
    final messageLength = _encodeVarInt(message.length);

    final buffer = ByteData(magicLength.length +
        magic.length +
        messageLength.length +
        message.length);

    int offset = 0;
    buffer.buffer
        .asUint8List()
        .setRange(offset, offset += magicLength.length, magicLength);
    buffer.buffer.asUint8List().setRange(offset, offset += magic.length, magic);
    buffer.buffer
        .asUint8List()
        .setRange(offset, offset += messageLength.length, messageLength);
    buffer.buffer
        .asUint8List()
        .setRange(offset, offset += message.length, message);

    return buffer.buffer.asUint8List();
  }

  Uint8List getHash() {
    final serialized = serialize();
    final sha256 = SHA256Digest();
    final firstHash = sha256.process(serialized);
    return sha256.process(firstHash);
  }

  static Uint8List _encodeVarInt(int value) {
    if (value < 0xfd) {
      return Uint8List.fromList([value]);
    } else if (value <= 0xffff) {
      final buffer = ByteData(3);
      buffer.setUint8(0, 0xfd);
      buffer.setUint16(1, value, Endian.little);
      return buffer.buffer.asUint8List();
    } else if (value <= 0xffffffff) {
      final buffer = ByteData(5);
      buffer.setUint8(0, 0xfe);
      buffer.setUint32(1, value, Endian.little);
      return buffer.buffer.asUint8List();
    } else {
      final buffer = ByteData(9);
      buffer.setUint8(0, 0xff);
      buffer.setUint64(1, value, Endian.little);
      return buffer.buffer.asUint8List();
    }
  }
}

String signMessage(ECPair key, EvrmoreMessage message) {
  final hash = message.getHash();
  final signature = key.sign(hash);
  final recoveryId = 0x03;

  // Add recovery ID and compression flag
  final meta = 27 + recoveryId + 4;

  final combined = Uint8List(65);
  combined[0] = meta;
  combined.setRange(1, 65, signature);

  return base64.encode(combined);
}

//bool verifyMessage(String address, EvrmoreMessage message, String signature) {
//  final signatureBytes = base64.decode(signature);
//  final hash = message.getHash();
//
//  // Extract recovery ID from meta
//  final meta = signatureBytes[0] - 27;
//  final recoveryId = meta & 0x03;
//  final isCompressed = (meta & 0x04) != 0;
//
//  final sig = signatureBytes.sublist(1);
//  final pubKey = PublicKey.recover(hash, sig, recoveryId, isCompressed);
//
//  return pubKey.toAddress() == address;
//}
