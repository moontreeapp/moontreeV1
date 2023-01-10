import 'package:client_back/client_back.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:client_back/records/types/chain.dart';
import 'package:client_back/records/types/net.dart';
import 'package:wallet_utils/wallet_utils.dart';

import '_type_id.dart';

part 'asset.g.dart';

@HiveType(typeId: TypeId.Asset)
class Asset with EquatableMixin {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final int satsInCirculation;

  @HiveField(2)
  final int divisibility;

  @HiveField(3)
  final bool reissuable;

  @HiveField(4)
  final String metadata;

  @HiveField(5)
  final String transactionId;

  @HiveField(6)
  final int position;

  @HiveField(7, defaultValue: Chain.ravencoin)
  final Chain chain;

  @HiveField(8, defaultValue: Net.main)
  final Net net;

  //late final TxSource source;
  ////late final String txHash; // where it originated?
  ////late final int txPos; // the vout it originated?
  ////late final int height; // the block it originated? // not necessary

  Asset({
    required this.symbol,
    required this.satsInCirculation,
    required this.divisibility,
    required this.reissuable,
    required this.metadata,
    required this.transactionId,
    required this.position,
    required this.chain,
    required this.net,
  }) {
    symbolSymbol = Symbol(symbol)(chain, net);
  }

  late Symbol symbolSymbol;

  @override
  List<Object> get props => <Object>[
        symbol,
        satsInCirculation,
        divisibility,
        reissuable,
        metadata,
        transactionId,
        position,
        chain,
        net,
      ];

  @override
  String toString() => 'Asset(symbol: $symbol, '
      'satsInCirculation: $satsInCirculation, divisibility: $divisibility, '
      'reissuable: $reissuable, metadata: $metadata, transactionId: $transactionId, '
      'position: $position, ${ChainNet(chain, net).readable})';

  factory Asset.from(
    Asset asset, {
    int? satsInCirculation,
    int? divisibility,
    bool? reissuable,
    String? metadata,
    String? transactionId,
    int? position,
    String? symbol,
    Chain? chain,
    Net? net,
  }) {
    return Asset(
      satsInCirculation: satsInCirculation ?? asset.satsInCirculation,
      divisibility: divisibility ?? asset.divisibility,
      reissuable: reissuable ?? asset.reissuable,
      metadata: metadata ?? asset.metadata,
      transactionId: transactionId ?? asset.transactionId,
      position: position ?? asset.position,
      symbol: symbol ?? (chain != null ? chain.symbol : asset.symbol),
      chain: chain ?? asset.chain,
      net: net ?? asset.net,
    );
  }

  /// about asset
  bool get hasData => metadata.isAssetData;
  String? get data => hasData ? metadata : null;
  bool get hasMetadata => metadata != '';
  double get amount => satsInCirculation.asCoin;

  /// key stuff
  static String key(String symbol, Chain chain, Net net) =>
      '$symbol:${ChainNet(chain, net).key}';
  String get id => key(symbol, chain, net);
  String? get parentId => symbolSymbol.parentSymbol == null
      ? null
      : key(symbolSymbol.parentSymbol!, chain, net);

  /// bringing symbol values to top level
  SymbolType get symbolType => symbolSymbol.symbolType;
  String get symbolTypeName => symbolSymbol.symbolTypeName;
  String get baseSymbol => symbolSymbol.baseSymbol;
  String get baseSubSymbol => symbolSymbol.baseSubSymbol;
  bool get isAdmin => symbolSymbol.isAdmin;
  bool get isSubAdmin => symbolSymbol.isSubAdmin;
  bool get isQualifier => symbolSymbol.isQualifier;
  bool get isAnySub => symbolSymbol.isAnySub;
  bool get isRestricted => symbolSymbol.isRestricted;
  bool get isMain => symbolSymbol.isMain;
  bool get isNFT => symbolSymbol.isNFT;
  bool get isChannel => symbolSymbol.isChannel;
}
