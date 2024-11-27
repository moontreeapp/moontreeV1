import 'package:magic/domain/wallet/sign/sign_message.dart';
import 'package:wallet_utils/wallet_utils.dart' show ECPair;

extension ExtendedECPair on ECPair {
  /// Signs a message with the private key of the ECPair.
  String signCompact(String message) {
    return SignMessage(
      message: message,
      prefix: network.messagePrefix,
    ).signCompact(privateKeyWIF: toWIF());
  }
}
