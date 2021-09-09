import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/utils/cipher.dart';

export 'extended_wallet_base.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  final String walletId;

  @HiveField(1)
  final String accountId;

  @override
  List<Object?> get props => [walletId, accountId];

  Wallet({required this.walletId, required this.accountId});

  Cipher get cipher => const NoCipher();

  String get kind => 'Wallet';

  String get secret => '';
}
