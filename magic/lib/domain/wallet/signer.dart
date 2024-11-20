import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/src/utils.dart';

class MessageSigner {
  final ECPrivateKey privateKey;
  final bool compressed;

  MessageSigner(this.privateKey, {this.compressed = true});

  Uint8List _sha256(Uint8List input) {
    return Uint8List.fromList(sha256.convert(input).bytes);
  }

  Uint8List _hashMessage(String message) {
    final prefix = '\x18Evrmore Signed Message:\n';
    final messageBytes = utf8.encode(message);
    final lengthBytes = _encodeVarInt(messageBytes.length);
    final prefixBytes = utf8.encode(prefix);

    final data = Uint8List.fromList(prefixBytes + lengthBytes + messageBytes);
    return _sha256(_sha256(data));
  }

  Uint8List _encodeVarInt(int length) {
    if (length < 0xfd) {
      return Uint8List.fromList([length]);
    } else if (length <= 0xffff) {
      return Uint8List.fromList([0xfd, length & 0xff, (length >> 8) & 0xff]);
    } else if (length <= 0xffffffff) {
      return Uint8List.fromList([
        0xfe,
        length & 0xff,
        (length >> 8) & 0xff,
        (length >> 16) & 0xff,
        (length >> 24) & 0xff
      ]);
    } else {
      throw ArgumentError('VarInt too large');
    }
  }

  String sign(String message) {
    final hashedMessage = _hashMessage(message);

    final curve = ECDomainParameters('secp256k1');
    final n = curve.n;
    final d = privateKey.d;
    final G = curve.G;

    final kCalculator = RFC6979KCalculator(SHA256Digest())
      ..init(n, d!, hashedMessage);

    BigInt k;
    ECPoint R;
    do {
      k = kCalculator.nextK();
      R = (G * k)!;
    } while (R.isInfinity);

    BigInt r = R.x!.toBigInteger()! % n;
    if (r == BigInt.zero) {
      throw StateError('Invalid signature: r is zero');
    }

    BigInt s = (k.modInverse(n) *
            (hashedMessageToBigInt(hashedMessage) + (d * r) % n)) %
        n;
    BigInt halfN = n >> 1;
    if (s.compareTo(halfN) > 0) {
      s = n - s;
    }

    final ecSignature = ECSignature(r, s);
    final sigBytes = _encodeSignature(ecSignature);
    final meta = 27 + (compressed ? 4 : 0);
    return base64Encode(Uint8List.fromList([meta] + sigBytes));
  }

  Uint8List _encodeSignature(ECSignature signature) {
    List<int> rBytes = encodeBigInt(signature.r);
    List<int> sBytes = encodeBigInt(signature.s);

    return Uint8List.fromList(rBytes + sBytes);
  }

  BigInt hashedMessageToBigInt(Uint8List hashedMessage) {
    return decodeBigInt(hashedMessage);
  }
}

class RFC6979KCalculator {
  final SHA256Digest hash;
  late BigInt n;
  late BigInt privateKey;
  late Uint8List message;
  late Uint8List _v;
  late Uint8List _k;

  RFC6979KCalculator(this.hash);

  void init(BigInt n, BigInt privateKey, Uint8List message) {
    this.n = n;
    this.privateKey = privateKey;
    this.message = message;

    _v = Uint8List(32)..fillRange(0, 32, 0x01);
    _k = Uint8List(32)..fillRange(0, 32, 0x00);

    final privateKeyBytes = encodeBigInt(privateKey);
    final hashBytes = hash.process(message);

    final hmac = HMac(hash, 64);
    hmac.init(KeyParameter(_k));

    hmac.update(_v, 0, _v.length);
    hmac.update(Uint8List.fromList([0x00]), 0, 1);
    hmac.update(privateKeyBytes, 0, privateKeyBytes.length);
    hmac.update(hashBytes, 0, hashBytes.length);
    _k = Uint8List(32);
    hmac.doFinal(_k, 0);

    hmac.init(KeyParameter(_k));
    hmac.update(_v, 0, _v.length);
    _v = Uint8List(32);
    hmac.doFinal(_v, 0);

    hmac.init(KeyParameter(_k));
    hmac.update(_v, 0, _v.length);
    hmac.update(Uint8List.fromList([0x01]), 0, 1);
    hmac.update(privateKeyBytes, 0, privateKeyBytes.length);
    hmac.update(hashBytes, 0, hashBytes.length);
    _k = Uint8List(32);
    hmac.doFinal(_k, 0);

    hmac.init(KeyParameter(_k));
    hmac.update(_v, 0, _v.length);
    _v = Uint8List(32);
    hmac.doFinal(_v, 0);
  }

  BigInt nextK() {
    final hmac = HMac(hash, 64);
    BigInt k;
    do {
      hmac.init(KeyParameter(_k));
      hmac.update(_v, 0, _v.length);
      _v = Uint8List(32);
      hmac.doFinal(_v, 0);
      k = decodeBigInt(_v);
    } while (k <= BigInt.zero || k >= n);
    return k;
  }
}

BigInt wifToPrivateKey(String wif) {
  final decoded = base58.decode(wif);
  if (decoded[0] != 0x80) {
    throw ArgumentError('Invalid WIF format');
  }
  final privateKeyBytes = decoded.sublist(1, decoded.length - 4);
  return BigInt.parse(hex.encode(privateKeyBytes), radix: 16);
}

String signer() {
  // Example usage:
  // You would need to replace the below private key with your actual private key.
  final wifPrivateKey = 'L1pJZ8Uw2nSNjjvRSCSAwoUfugMaknTbFAU5yRPQ1cJHvXVaM7FD';
  final privateKeyHex = wifToPrivateKey(wifPrivateKey);
  final privateKey =
      ECPrivateKey(privateKeyHex, ECDomainParameters('secp256k1'));

  final signer = MessageSigner(privateKey);
  final message = '1731910549.8774903';
  final signature = signer.sign(message);

  print('Signature: $signature');
  return signature;
}
