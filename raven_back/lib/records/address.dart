import 'package:hive/hive.dart';
import 'package:raven/models/balance.dart';

import 'node_exposure.dart';
import 'net.dart';

part 'address.g.dart';

@HiveType(typeId: 2)
class Address {
  @HiveField(0)
  String scripthash;

  @HiveField(1)
  String address;

  @HiveField(2)
  String walletId;

  @HiveField(3)
  String accountId;

  @HiveField(4)
  int hdIndex;

  @HiveField(5)
  NodeExposure exposure;

  @HiveField(6)
  Net net;

  @HiveField(7)
  Map<String, Balance>? balances;

  Address({
    required this.scripthash,
    required this.address,
    required this.walletId,
    required this.accountId,
    required this.hdIndex,
    this.exposure = NodeExposure.External,
    this.net = Net.Test,
    this.balances,
  });
}
