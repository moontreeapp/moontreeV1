import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/security.dart';

import '_type_id.dart';

part 'vout.g.dart';

@HiveType(typeId: TypeId.Vout)
class Vout with EquatableMixin {
  @HiveField(0)
  String txId;

  @HiveField(1)
  int rvnValue; // always RVN

  @HiveField(2)
  int position;

  @HiveField(3)
  String memo;

  /// other values include
  // final double value;
  // final TxScriptPubKey scriptPubKey; // has pertinent information

  // transaction type 'pubkeyhash' 'transfer_asset' 'new_asset' 'nulldata' etc
  @HiveField(4)
  String type;

  @HiveField(5) // non-multisig transactions
  String toAddress;

  @HiveField(6)
  String? assetSecurityId;

  @HiveField(8)
  int? assetValue; // amount of asset to send

  @HiveField(9) // multisig
  List<String>? additionalAddresses;

  Vout({
    required this.txId,
    required this.rvnValue,
    required this.position,
    this.memo = '',
    required this.type,
    required this.toAddress,
    this.assetSecurityId,
    this.assetValue,
    this.additionalAddresses,
  });

  bool get confirmed => position > -1;

  @override
  List<Object?> get props => [
        txId,
        rvnValue,
        position,
        memo,
        type,
        toAddress,
        assetSecurityId,
        assetValue,
        additionalAddresses,
      ];

  @override
  bool? get stringify => true;

  String get voutId => getVoutId(txId, position);
  static String getVoutId(txId, position) => '$txId:$position';

  List<String> get toAddresses => [toAddress, ...additionalAddresses ?? []];
}