/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'asset_class.dart' as _i2;
import 'asset_metadata_class.dart' as _i3;
import 'asset_metadata_history_class.dart' as _i4;
import 'block_class.dart' as _i5;
import 'chain_class.dart' as _i6;
import 'comm_balance_view.dart' as _i7;
import 'comm_notify_h160_balance.dart' as _i8;
import 'comm_notify_height.dart' as _i9;
import 'comm_notify_status.dart' as _i10;
import 'comm_notify_wallet_balance.dart' as _i11;
import 'comm_subscribe.dart' as _i12;
import 'comm_transaction_details_view.dart' as _i13;
import 'comm_transaction_view.dart' as _i14;
import 'consent_class.dart' as _i15;
import 'consent_document_class.dart' as _i16;
import 'h160_balance_current_class.dart' as _i17;
import 'h160_balance_incremental_class.dart' as _i18;
import 'h160_class.dart' as _i19;
import 'restricted_h160_freeze_link_class.dart' as _i20;
import 'restricted_h160_freeze_link_history_class.dart' as _i21;
import 'restricted_h160_qualification_history_class.dart' as _i22;
import 'restricted_h160_qualification_link_class.dart' as _i23;
import 'transaction_asset_link.dart' as _i24;
import 'transaction_class.dart' as _i25;
import 'vout_class.dart' as _i26;
import 'wallet_balance_current_class.dart' as _i27;
import 'wallet_balance_incremental_class.dart' as _i28;
import 'wallet_chain_link.dart' as _i29;
import 'wallet_class.dart' as _i30;
import 'asset_metadata_class.dart' as _i31;
import 'comm_balance_view.dart' as _i32;
import 'dart:typed_data' as _i33;
import 'comm_transaction_view.dart' as _i34;
export 'asset_class.dart';
export 'asset_metadata_class.dart';
export 'asset_metadata_history_class.dart';
export 'block_class.dart';
export 'chain_class.dart';
export 'comm_balance_view.dart';
export 'comm_notify_h160_balance.dart';
export 'comm_notify_height.dart';
export 'comm_notify_status.dart';
export 'comm_notify_wallet_balance.dart';
export 'comm_subscribe.dart';
export 'comm_transaction_details_view.dart';
export 'comm_transaction_view.dart';
export 'consent_class.dart';
export 'consent_document_class.dart';
export 'h160_balance_current_class.dart';
export 'h160_balance_incremental_class.dart';
export 'h160_class.dart';
export 'restricted_h160_freeze_link_class.dart';
export 'restricted_h160_freeze_link_history_class.dart';
export 'restricted_h160_qualification_history_class.dart';
export 'restricted_h160_qualification_link_class.dart';
export 'transaction_asset_link.dart';
export 'transaction_class.dart';
export 'vout_class.dart';
export 'wallet_balance_current_class.dart';
export 'wallet_balance_incremental_class.dart';
export 'wallet_chain_link.dart';
export 'wallet_class.dart';
export 'client.dart'; // ignore_for_file: equal_keys_in_map

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Map<Type, _i1.constructor> customConstructors = {};

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (customConstructors.containsKey(t)) {
      return customConstructors[t]!(data, this) as T;
    }
    if (t == _i2.Asset) {
      return _i2.Asset.fromJson(data, this) as T;
    }
    if (t == _i3.AssetMetadata) {
      return _i3.AssetMetadata.fromJson(data, this) as T;
    }
    if (t == _i4.AssetMetadataHistory) {
      return _i4.AssetMetadataHistory.fromJson(data, this) as T;
    }
    if (t == _i5.BlockchainBlock) {
      return _i5.BlockchainBlock.fromJson(data, this) as T;
    }
    if (t == _i6.Chain) {
      return _i6.Chain.fromJson(data, this) as T;
    }
    if (t == _i7.BalanceView) {
      return _i7.BalanceView.fromJson(data, this) as T;
    }
    if (t == _i8.NotifyChainH160Balance) {
      return _i8.NotifyChainH160Balance.fromJson(data, this) as T;
    }
    if (t == _i9.NotifyChainHeight) {
      return _i9.NotifyChainHeight.fromJson(data, this) as T;
    }
    if (t == _i10.NotifyChainStatus) {
      return _i10.NotifyChainStatus.fromJson(data, this) as T;
    }
    if (t == _i11.NotifyChainWalletBalance) {
      return _i11.NotifyChainWalletBalance.fromJson(data, this) as T;
    }
    if (t == _i12.ChainWalletH160Subscription) {
      return _i12.ChainWalletH160Subscription.fromJson(data, this) as T;
    }
    if (t == _i13.TransactionDetailsView) {
      return _i13.TransactionDetailsView.fromJson(data, this) as T;
    }
    if (t == _i14.TransactionView) {
      return _i14.TransactionView.fromJson(data, this) as T;
    }
    if (t == _i15.Consent) {
      return _i15.Consent.fromJson(data, this) as T;
    }
    if (t == _i16.ConsentDocument) {
      return _i16.ConsentDocument.fromJson(data, this) as T;
    }
    if (t == _i17.AddressBalanceCurrent) {
      return _i17.AddressBalanceCurrent.fromJson(data, this) as T;
    }
    if (t == _i18.AddressBalanceIncremental) {
      return _i18.AddressBalanceIncremental.fromJson(data, this) as T;
    }
    if (t == _i19.H160) {
      return _i19.H160.fromJson(data, this) as T;
    }
    if (t == _i20.RestrictedH160FreezeLink) {
      return _i20.RestrictedH160FreezeLink.fromJson(data, this) as T;
    }
    if (t == _i21.RestrictedH160FreezeLinkHistory) {
      return _i21.RestrictedH160FreezeLinkHistory.fromJson(data, this) as T;
    }
    if (t == _i22.RestrictedH160QualificationLinkHistory) {
      return _i22.RestrictedH160QualificationLinkHistory.fromJson(data, this)
          as T;
    }
    if (t == _i23.RestrictedH160QualificationLink) {
      return _i23.RestrictedH160QualificationLink.fromJson(data, this) as T;
    }
    if (t == _i24.TransctionAssetLink) {
      return _i24.TransctionAssetLink.fromJson(data, this) as T;
    }
    if (t == _i25.BlockchainTransaction) {
      return _i25.BlockchainTransaction.fromJson(data, this) as T;
    }
    if (t == _i26.Vout) {
      return _i26.Vout.fromJson(data, this) as T;
    }
    if (t == _i27.WalletBalanceCurrent) {
      return _i27.WalletBalanceCurrent.fromJson(data, this) as T;
    }
    if (t == _i28.WalletBalanceIncremental) {
      return _i28.WalletBalanceIncremental.fromJson(data, this) as T;
    }
    if (t == _i29.WalletChainLink) {
      return _i29.WalletChainLink.fromJson(data, this) as T;
    }
    if (t == _i30.Wallet) {
      return _i30.Wallet.fromJson(data, this) as T;
    }
    if (t == _i1.getType<_i2.Asset?>()) {
      return (data != null ? _i2.Asset.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i3.AssetMetadata?>()) {
      return (data != null ? _i3.AssetMetadata.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i4.AssetMetadataHistory?>()) {
      return (data != null
          ? _i4.AssetMetadataHistory.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i5.BlockchainBlock?>()) {
      return (data != null ? _i5.BlockchainBlock.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i6.Chain?>()) {
      return (data != null ? _i6.Chain.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i7.BalanceView?>()) {
      return (data != null ? _i7.BalanceView.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i8.NotifyChainH160Balance?>()) {
      return (data != null
          ? _i8.NotifyChainH160Balance.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i9.NotifyChainHeight?>()) {
      return (data != null ? _i9.NotifyChainHeight.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i10.NotifyChainStatus?>()) {
      return (data != null ? _i10.NotifyChainStatus.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i11.NotifyChainWalletBalance?>()) {
      return (data != null
          ? _i11.NotifyChainWalletBalance.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i12.ChainWalletH160Subscription?>()) {
      return (data != null
          ? _i12.ChainWalletH160Subscription.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i13.TransactionDetailsView?>()) {
      return (data != null
          ? _i13.TransactionDetailsView.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i14.TransactionView?>()) {
      return (data != null ? _i14.TransactionView.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i15.Consent?>()) {
      return (data != null ? _i15.Consent.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i16.ConsentDocument?>()) {
      return (data != null ? _i16.ConsentDocument.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i17.AddressBalanceCurrent?>()) {
      return (data != null
          ? _i17.AddressBalanceCurrent.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i18.AddressBalanceIncremental?>()) {
      return (data != null
          ? _i18.AddressBalanceIncremental.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i19.H160?>()) {
      return (data != null ? _i19.H160.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i20.RestrictedH160FreezeLink?>()) {
      return (data != null
          ? _i20.RestrictedH160FreezeLink.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i21.RestrictedH160FreezeLinkHistory?>()) {
      return (data != null
          ? _i21.RestrictedH160FreezeLinkHistory.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i22.RestrictedH160QualificationLinkHistory?>()) {
      return (data != null
          ? _i22.RestrictedH160QualificationLinkHistory.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i23.RestrictedH160QualificationLink?>()) {
      return (data != null
          ? _i23.RestrictedH160QualificationLink.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i24.TransctionAssetLink?>()) {
      return (data != null
          ? _i24.TransctionAssetLink.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i25.BlockchainTransaction?>()) {
      return (data != null
          ? _i25.BlockchainTransaction.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i26.Vout?>()) {
      return (data != null ? _i26.Vout.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i27.WalletBalanceCurrent?>()) {
      return (data != null
          ? _i27.WalletBalanceCurrent.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i28.WalletBalanceIncremental?>()) {
      return (data != null
          ? _i28.WalletBalanceIncremental.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i29.WalletChainLink?>()) {
      return (data != null ? _i29.WalletChainLink.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i30.Wallet?>()) {
      return (data != null ? _i30.Wallet.fromJson(data, this) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList()
          as dynamic;
    }
    if (t == List<_i31.AssetMetadata>) {
      return (data as List)
          .map((e) => deserialize<_i31.AssetMetadata>(e))
          .toList() as dynamic;
    }
    if (t == List<_i32.BalanceView>) {
      return (data as List)
          .map((e) => deserialize<_i32.BalanceView>(e))
          .toList() as dynamic;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList()
          as dynamic;
    }
    if (t == List<_i33.ByteData>) {
      return (data as List).map((e) => deserialize<_i33.ByteData>(e)).toList()
          as dynamic;
    }
    if (t == List<_i34.TransactionView>) {
      return (data as List)
          .map((e) => deserialize<_i34.TransactionView>(e))
          .toList() as dynamic;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    if (data is _i2.Asset) {
      return 'Asset';
    }
    if (data is _i3.AssetMetadata) {
      return 'AssetMetadata';
    }
    if (data is _i4.AssetMetadataHistory) {
      return 'AssetMetadataHistory';
    }
    if (data is _i5.BlockchainBlock) {
      return 'BlockchainBlock';
    }
    if (data is _i6.Chain) {
      return 'Chain';
    }
    if (data is _i7.BalanceView) {
      return 'BalanceView';
    }
    if (data is _i8.NotifyChainH160Balance) {
      return 'NotifyChainH160Balance';
    }
    if (data is _i9.NotifyChainHeight) {
      return 'NotifyChainHeight';
    }
    if (data is _i10.NotifyChainStatus) {
      return 'NotifyChainStatus';
    }
    if (data is _i11.NotifyChainWalletBalance) {
      return 'NotifyChainWalletBalance';
    }
    if (data is _i12.ChainWalletH160Subscription) {
      return 'ChainWalletH160Subscription';
    }
    if (data is _i13.TransactionDetailsView) {
      return 'TransactionDetailsView';
    }
    if (data is _i14.TransactionView) {
      return 'TransactionView';
    }
    if (data is _i15.Consent) {
      return 'Consent';
    }
    if (data is _i16.ConsentDocument) {
      return 'ConsentDocument';
    }
    if (data is _i17.AddressBalanceCurrent) {
      return 'AddressBalanceCurrent';
    }
    if (data is _i18.AddressBalanceIncremental) {
      return 'AddressBalanceIncremental';
    }
    if (data is _i19.H160) {
      return 'H160';
    }
    if (data is _i20.RestrictedH160FreezeLink) {
      return 'RestrictedH160FreezeLink';
    }
    if (data is _i21.RestrictedH160FreezeLinkHistory) {
      return 'RestrictedH160FreezeLinkHistory';
    }
    if (data is _i22.RestrictedH160QualificationLinkHistory) {
      return 'RestrictedH160QualificationLinkHistory';
    }
    if (data is _i23.RestrictedH160QualificationLink) {
      return 'RestrictedH160QualificationLink';
    }
    if (data is _i24.TransctionAssetLink) {
      return 'TransctionAssetLink';
    }
    if (data is _i25.BlockchainTransaction) {
      return 'BlockchainTransaction';
    }
    if (data is _i26.Vout) {
      return 'Vout';
    }
    if (data is _i27.WalletBalanceCurrent) {
      return 'WalletBalanceCurrent';
    }
    if (data is _i28.WalletBalanceIncremental) {
      return 'WalletBalanceIncremental';
    }
    if (data is _i29.WalletChainLink) {
      return 'WalletChainLink';
    }
    if (data is _i30.Wallet) {
      return 'Wallet';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'Asset') {
      return deserialize<_i2.Asset>(data['data']);
    }
    if (data['className'] == 'AssetMetadata') {
      return deserialize<_i3.AssetMetadata>(data['data']);
    }
    if (data['className'] == 'AssetMetadataHistory') {
      return deserialize<_i4.AssetMetadataHistory>(data['data']);
    }
    if (data['className'] == 'BlockchainBlock') {
      return deserialize<_i5.BlockchainBlock>(data['data']);
    }
    if (data['className'] == 'Chain') {
      return deserialize<_i6.Chain>(data['data']);
    }
    if (data['className'] == 'BalanceView') {
      return deserialize<_i7.BalanceView>(data['data']);
    }
    if (data['className'] == 'NotifyChainH160Balance') {
      return deserialize<_i8.NotifyChainH160Balance>(data['data']);
    }
    if (data['className'] == 'NotifyChainHeight') {
      return deserialize<_i9.NotifyChainHeight>(data['data']);
    }
    if (data['className'] == 'NotifyChainStatus') {
      return deserialize<_i10.NotifyChainStatus>(data['data']);
    }
    if (data['className'] == 'NotifyChainWalletBalance') {
      return deserialize<_i11.NotifyChainWalletBalance>(data['data']);
    }
    if (data['className'] == 'ChainWalletH160Subscription') {
      return deserialize<_i12.ChainWalletH160Subscription>(data['data']);
    }
    if (data['className'] == 'TransactionDetailsView') {
      return deserialize<_i13.TransactionDetailsView>(data['data']);
    }
    if (data['className'] == 'TransactionView') {
      return deserialize<_i14.TransactionView>(data['data']);
    }
    if (data['className'] == 'Consent') {
      return deserialize<_i15.Consent>(data['data']);
    }
    if (data['className'] == 'ConsentDocument') {
      return deserialize<_i16.ConsentDocument>(data['data']);
    }
    if (data['className'] == 'AddressBalanceCurrent') {
      return deserialize<_i17.AddressBalanceCurrent>(data['data']);
    }
    if (data['className'] == 'AddressBalanceIncremental') {
      return deserialize<_i18.AddressBalanceIncremental>(data['data']);
    }
    if (data['className'] == 'H160') {
      return deserialize<_i19.H160>(data['data']);
    }
    if (data['className'] == 'RestrictedH160FreezeLink') {
      return deserialize<_i20.RestrictedH160FreezeLink>(data['data']);
    }
    if (data['className'] == 'RestrictedH160FreezeLinkHistory') {
      return deserialize<_i21.RestrictedH160FreezeLinkHistory>(data['data']);
    }
    if (data['className'] == 'RestrictedH160QualificationLinkHistory') {
      return deserialize<_i22.RestrictedH160QualificationLinkHistory>(
          data['data']);
    }
    if (data['className'] == 'RestrictedH160QualificationLink') {
      return deserialize<_i23.RestrictedH160QualificationLink>(data['data']);
    }
    if (data['className'] == 'TransctionAssetLink') {
      return deserialize<_i24.TransctionAssetLink>(data['data']);
    }
    if (data['className'] == 'BlockchainTransaction') {
      return deserialize<_i25.BlockchainTransaction>(data['data']);
    }
    if (data['className'] == 'Vout') {
      return deserialize<_i26.Vout>(data['data']);
    }
    if (data['className'] == 'WalletBalanceCurrent') {
      return deserialize<_i27.WalletBalanceCurrent>(data['data']);
    }
    if (data['className'] == 'WalletBalanceIncremental') {
      return deserialize<_i28.WalletBalanceIncremental>(data['data']);
    }
    if (data['className'] == 'WalletChainLink') {
      return deserialize<_i29.WalletChainLink>(data['data']);
    }
    if (data['className'] == 'Wallet') {
      return deserialize<_i30.Wallet>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
