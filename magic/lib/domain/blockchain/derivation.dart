import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';

/// bip 44: m / purpose' / coin_type' / account' / change / index
String getDerivationPath({
  Blockchain? blockchain,
  String master = "m",
  int purpose = 44, //bip
  int coinType = 175,
  int account = 0,
  Exposure exposure = Exposure.external,
  int? index,
}) =>
    "$master"
    "/${blockchain?.purpose ?? purpose}'"
    "/${blockchain?.coinType ?? coinType}'"
    "/$account'"
    "/${exposure.indexStr}"
    "${index == null ? '' : '/$index'}";