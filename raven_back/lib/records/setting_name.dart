import 'package:hive/hive.dart';

import '_type_id.dart';

part 'setting_name.g.dart';

/// Namespace_SettingName

@HiveType(typeId: TypeId.SettingName)
enum SettingName {
  @HiveField(0)
  Database_Version,

  @HiveField(1)
  Electrum_Net,

  @HiveField(2)
  Electrum_Domain,

  @HiveField(3)
  Electrum_Port,

  @HiveField(4)
  Electrum_DomainTest,

  @HiveField(5)
  Electrum_PortTest,

  @HiveField(6)
  Wallet_Current,

  @HiveField(7)
  Wallet_Preferred,

  @HiveField(8)
  Local_Path,

  @HiveField(9)
  User_Name,

  @HiveField(10)
  Send_Immediate,

  @HiveField(11)
  Login_Attempts,
}
