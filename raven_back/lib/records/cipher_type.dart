import 'package:hive/hive.dart';

import '_type_id.dart';

part 'cipher_type.g.dart';

@HiveType(typeId: TypeId.CipherType)
enum CipherType {
  @HiveField(0)
  CipherNone,

  @HiveField(1)
  CipherAES,
}
