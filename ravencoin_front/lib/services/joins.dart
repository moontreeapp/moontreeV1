import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/services/storage.dart';

extension WalletHasASecret on Wallet {
  Future<String?> get secureSecret async => await SecureStorage.read(id);
  Future<String?> get enrtopy async => await secureSecret;
}