import 'account.dart';
import 'address.dart';
import 'app.dart';
import 'cipher.dart';
import 'client.dart';
import 'password.dart';
import 'wallet.dart';

class streams {
  static final account = AccountStreams();
  static final address = AddressStreams();
  static final app = AppStreams();
  static final cipher = CipherStreams();
  static final client = ClientStreams();
  static final password = PasswordStreams();
  static final wallet = WalletStreams();
}


/// make two streams that record when the list of addresses that haven't been pulled is empty.