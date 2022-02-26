/// used to aggregate multiple balances into one asset tree
// ignore_for_file: omit_local_variable_types

import 'package:raven_back/raven_back.dart';

Map<String, AssetHolding> assetHoldings(Iterable<Balance> holdings) {
  Map<String, AssetHolding> balances = {};
  for (var balance in holdings) {
    var baseSymbol =
        balance.security.asset?.baseSymbol ?? balance.security.symbol;
    var assetType =
        balance.security.asset?.assetType ?? balance.security.securityType;
    if (!balances.containsKey(baseSymbol)) {
      balances[baseSymbol] = AssetHolding(
        symbol: baseSymbol,
        main: assetType == AssetType.Main ? balance : null,
        admin: assetType == AssetType.Admin ? balance : null,
        restricted: assetType == AssetType.Restricted ? balance : null,
        restrictedAdmin:
            assetType == AssetType.RestrictedAdmin ? balance : null,
        nft: assetType == AssetType.NFT ? balance : null,
        channel: assetType == AssetType.Channel ? balance : null,
        sub: assetType == AssetType.Sub ? balance : null,
        subAdmin: assetType == AssetType.SubAdmin ? balance : null,
        qualifier: assetType == AssetType.Qualifier ? balance : null,
        qualifierSub: assetType == AssetType.QualifierSub ? balance : null,
        crypto: assetType == SecurityType.Crypto ? balance : null,
        fiat: assetType == SecurityType.Fiat ? balance : null,
      );
    } else {
      balances[baseSymbol] = AssetHolding.fromAssetHolding(
        balances[baseSymbol]!,
        main: assetType == AssetType.Main ? balance : null,
        admin: assetType == AssetType.Admin ? balance : null,
        restricted: assetType == AssetType.Restricted ? balance : null,
        restrictedAdmin:
            assetType == AssetType.RestrictedAdmin ? balance : null,
        nft: assetType == AssetType.NFT ? balance : null,
        channel: assetType == AssetType.Channel ? balance : null,
        sub: assetType == AssetType.Sub ? balance : null,
        subAdmin: assetType == AssetType.SubAdmin ? balance : null,
        qualifier: assetType == AssetType.Qualifier ? balance : null,
        qualifierSub: assetType == AssetType.QualifierSub ? balance : null,
        crypto: assetType == SecurityType.Crypto ? balance : null,
        fiat: assetType == SecurityType.Fiat ? balance : null,
      );
    }
  }
  return balances;
}

Balance blank(Asset asset) => Balance(
    walletId: '',
    confirmed: 0,
    unconfirmed: 0,
    security: asset.security ??
        Security(securityType: SecurityType.RavenAsset, symbol: asset.symbol));

Map<String, AssetHolding> assetHoldingsFromAssets(String parent) {
  Map<String, AssetHolding> assets = {};
  for (var asset in res.assets) {
    var assetType = asset.assetType;
    if (!assets.containsKey(asset.baseSubSymbol)) {
      assets[asset.baseSubSymbol] = AssetHolding(
        symbol: asset.baseSubSymbol,
        main: assetType == AssetType.Main ? blank(asset) : null,
        admin: assetType == AssetType.Admin ? blank(asset) : null,
        restricted: assetType == AssetType.Restricted ? blank(asset) : null,
        qualifier: assetType == AssetType.Qualifier ? blank(asset) : null,
        unique: assetType == AssetType.NFT ? blank(asset) : null,
        channel: assetType == AssetType.Channel ? blank(asset) : null,
        //crypto: assetType == SecurityType.Crypto ? blank(asset) : null,
        //fiat: assetType == SecurityType.Fiat ? blank(asset) : null,
      );
    } else {
      assets[asset.baseSubSymbol] = AssetHolding.fromAssetHolding(
        assets[asset.baseSubSymbol]!,
        main: assetType == AssetType.Main ? blank(asset) : null,
        admin: assetType == AssetType.Admin ? blank(asset) : null,
        restricted: assetType == AssetType.Restricted ? blank(asset) : null,
        qualifier: assetType == AssetType.Qualifier ? blank(asset) : null,
        unique: assetType == AssetType.NFT ? blank(asset) : null,
        channel: assetType == AssetType.Channel ? blank(asset) : null,
        //crypto: assetType == SecurityType.Crypto ? blank(asset) : null,
        //fiat: assetType == SecurityType.Fiat ? blank(asset) : null,
      );
    }
  }
  return assets;
}
