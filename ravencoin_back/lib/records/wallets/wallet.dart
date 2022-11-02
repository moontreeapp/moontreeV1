import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

export 'extended_wallet_base.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final CipherUpdate cipherUpdate;

  @HiveField(2)
  final String name;

  @HiveField(3)
  bool backedUp;

  @HiveField(4, defaultValue: false)
  bool skipHistory;

  @override
  List<Object?> get props => [id, cipherUpdate, name, backedUp, skipHistory];

  Wallet({
    required this.id,
    required this.cipherUpdate,
    this.backedUp = false,
    this.skipHistory = false,
    String? name,
  }) : name = name ?? (id.length > 5 ? id.substring(0, 6) : id[0]);

  String get encrypted;

  Future<String> secret(CipherBase cipher);

  // seemingly unused...
  Future<WalletBase> seedWallet(
    CipherBase cipher, {
    Chain chain = Chain.ravencoin,
    Net net = Net.main,
  });

  SecretType get secretType => SecretType.none;
  WalletType get walletType => WalletType.none;

  String get secretTypeToString => secretType.name;
  String get walletTypeToString => walletType.name;

  bool get minerMode => skipHistory;
}
