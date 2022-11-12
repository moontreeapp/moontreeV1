import 'package:hive/hive.dart';
import 'package:ravencoin_back/extensions/string.dart';
import 'package:ravencoin_back/records/types/net.dart';
import 'package:ravencoin_wallet/src/models/networks.dart'
    show NetworkType, mainnet, testnet, evrmoreMainnet, evrmoreTestnet;
import '../_type_id.dart';

part 'chain.g.dart';

//var chains = {
//  Chain.ravencoin: ravencoin,
//  Chain.evrmore: evrmore,
//};

@HiveType(typeId: TypeId.Chain)
enum Chain {
  @HiveField(0)
  none,

  @HiveField(1)
  evrmore,

  @HiveField(2)
  ravencoin,
}

String chainSymbol(Chain chain) {
  switch (chain) {
    case Chain.ravencoin:
      return 'RVN';
    case Chain.evrmore:
      return 'EVR';
    case Chain.none:
      return '';
    default:
      return 'RVN';
  }
}

String chainName(Chain chain) => chain.name.toTitleCase();

String chainNetSymbol(Chain chain, Net net) =>
    chainSymbol(chain) + netSymbolModifier(net);

String chainKey(Chain chain) => chain.name;

String chainNetKey(Chain chain, Net net) => chainKey(chain) + ':' + netKey(net);

String chainReadable(Chain chain) => 'chain: ${chain.name}';
String chainNetReadable(Chain chain, Net net) =>
    '${chainReadable(chain)}, ${netReadable(net)}';

NetworkType networkOf(Chain chain, Net net) {
  switch ([chain, net]) {
    case [Chain.ravencoin, Net.main]:
      return mainnet;
    case [Chain.ravencoin, Net.test]:
      return testnet;
    case [Chain.evrmore, Net.main]:
      return evrmoreMainnet;
    case [Chain.evrmore, Net.test]:
      return evrmoreTestnet;
    default:
      return mainnet;
  }
}

/// port map
///50001 - mainnet tcp
///50002 - mainnet ssl
///50011 - testnet tcp
///50012 - testnet ssl
int portOf(Chain chain, Net net) {
  switch ([chain, net]) {
    case [Chain.ravencoin, Net.main]:
      return 50002;
    case [Chain.ravencoin, Net.test]:
      return 50012;
    case [Chain.evrmore, Net.main]:
      return 8820;
    case [Chain.evrmore, Net.test]:
      return 18820;
    default:
      return 50002;
  }
}
