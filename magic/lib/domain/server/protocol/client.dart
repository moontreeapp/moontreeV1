/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:magic/domain/server/protocol/comm_int.dart' as _i3;
import 'package:magic/domain/server/protocol/comm_asset_metadata_response.dart'
    as _i4;
import 'package:magic/domain/server/protocol/comm_unsigned_transaction_result_class.dart'
    as _i5;
import 'package:magic/domain/server/protocol/comm_asset_create.dart' as _i6;
import 'package:magic/domain/server/protocol/comm_asset_reissue.dart' as _i7;
import 'package:magic/domain/server/protocol/comm_asset_global_freeze.dart'
    as _i8;
import 'package:magic/domain/server/protocol/comm_asset_tag_address.dart'
    as _i9;
import 'package:magic/domain/server/protocol/comm_balance_view.dart' as _i10;
import 'dart:typed_data' as _i11;
import 'package:magic/domain/server/protocol/comm_transaction_view.dart'
    as _i12;
import 'package:magic/domain/server/protocol/comm_string.dart' as _i13;
import 'package:magic/domain/server/protocol/comm_transaction_details_view.dart'
    as _i14;
import 'package:magic/domain/server/protocol/comm_ps_transaction_request_class.dart'
    as _i15;
import 'package:magic/domain/server/protocol/comm_unsigned_transaction_request_class.dart'
    as _i16;
import 'dart:io' as _i17;
import 'protocol.dart' as _i18;

class _EndpointAddresses extends _i1.EndpointRef {
  _EndpointAddresses(super.caller);

  @override
  String get name => 'addresses';

  _i2.Future<_i3.CommInt> nextEmptyIndex({
    required String chainName,
    required String xpubkey,
  }) =>
      caller.callServerEndpoint<_i3.CommInt>(
        'addresses',
        'nextEmptyIndex',
        {
          'chainName': chainName,
          'xpubkey': xpubkey,
        },
      );
}

class _EndpointMetadata extends _i1.EndpointRef {
  _EndpointMetadata(super.caller);

  @override
  String get name => 'metadata';

  /// generateMetadata returns a empty list or a list with one item in it so why
  /// are we passing a list back here when we could just pass AssetMetadata or
  /// null? Because of the height variable (which is basically ignored at the
  /// moment). In the future we may want to the history of changes of asset
  /// metadata, so we're set up to easily pivot to that scenario. Furthermore,
  /// most the other endpoints return lists so the front end is used to it.
  /// Of course maybe we'd just make a different endpoint for history, but idk.
  _i2.Future<_i4.AssetMetadataResponse> get({
    required String symbol,
    required String chainName,
    int? height,
  }) =>
      caller.callServerEndpoint<_i4.AssetMetadataResponse>(
        'metadata',
        'get',
        {
          'symbol': symbol,
          'chainName': chainName,
          'height': height,
        },
      );
}

class _EndpointCreateAsset extends _i1.EndpointRef {
  _EndpointCreateAsset(super.caller);

  @override
  String get name => 'createAsset';

  _i2.Future<_i5.UnsignedTransactionResult> generateAssetCreationTransaction({
    required _i6.AssetCreationRequest request,
    required String chainName,
  }) =>
      caller.callServerEndpoint<_i5.UnsignedTransactionResult>(
        'createAsset',
        'generateAssetCreationTransaction',
        {
          'request': request,
          'chainName': chainName,
        },
      );
}

class _EndpointReissueAsset extends _i1.EndpointRef {
  _EndpointReissueAsset(super.caller);

  @override
  String get name => 'reissueAsset';

  _i2.Future<_i5.UnsignedTransactionResult> generateAssetReissueTransaction({
    required _i7.AssetReissueRequest request,
    required String chainName,
  }) =>
      caller.callServerEndpoint<_i5.UnsignedTransactionResult>(
        'reissueAsset',
        'generateAssetReissueTransaction',
        {
          'request': request,
          'chainName': chainName,
        },
      );
}

class _EndpointFreezeRestrictedAsset extends _i1.EndpointRef {
  _EndpointFreezeRestrictedAsset(super.caller);

  @override
  String get name => 'freezeRestrictedAsset';

  _i2.Future<_i5.UnsignedTransactionResult> generateGlobalFreezeTransaction({
    required _i8.AssetGlobalFreezeRequest request,
    required String chainName,
  }) =>
      caller.callServerEndpoint<_i5.UnsignedTransactionResult>(
        'freezeRestrictedAsset',
        'generateGlobalFreezeTransaction',
        {
          'request': request,
          'chainName': chainName,
        },
      );
}

class _EndpointTagAddress extends _i1.EndpointRef {
  _EndpointTagAddress(super.caller);

  @override
  String get name => 'tagAddress';

  _i2.Future<_i5.UnsignedTransactionResult> generateAddressTagTransaction({
    required _i9.AssetAddressTagRequest request,
    required String chainName,
  }) =>
      caller.callServerEndpoint<_i5.UnsignedTransactionResult>(
        'tagAddress',
        'generateAddressTagTransaction',
        {
          'request': request,
          'chainName': chainName,
        },
      );
}

class _EndpointBalances extends _i1.EndpointRef {
  _EndpointBalances(super.caller);

  @override
  String get name => 'balances';

  _i2.Future<List<_i10.BalanceView>> get({
    required String chainName,
    required List<String> xpubkeys,
    required List<_i11.ByteData> h160s,
  }) =>
      caller.callServerEndpoint<List<_i10.BalanceView>>(
        'balances',
        'get',
        {
          'chainName': chainName,
          'xpubkeys': xpubkeys,
          'h160s': h160s,
        },
      );
}

class _EndpointCirculatingSats extends _i1.EndpointRef {
  _EndpointCirculatingSats(super.caller);

  @override
  String get name => 'circulatingSats';

  _i2.Future<_i3.CommInt> get({required String chainName}) =>
      caller.callServerEndpoint<_i3.CommInt>(
        'circulatingSats',
        'get',
        {'chainName': chainName},
      );
}

class _EndpointConsent extends _i1.EndpointRef {
  _EndpointConsent(super.caller);

  @override
  String get name => 'consent';

  _i2.Future<String> given(
    String deviceId,
    String documentName,
  ) =>
      caller.callServerEndpoint<String>(
        'consent',
        'given',
        {
          'deviceId': deviceId,
          'documentName': documentName,
        },
      );
}

class _EndpointHasGiven extends _i1.EndpointRef {
  _EndpointHasGiven(super.caller);

  @override
  String get name => 'hasGiven';

  _i2.Future<bool> consent(
    String deviceId,
    String documentName,
  ) =>
      caller.callServerEndpoint<bool>(
        'hasGiven',
        'consent',
        {
          'deviceId': deviceId,
          'documentName': documentName,
        },
      );
}

class _EndpointDocument extends _i1.EndpointRef {
  _EndpointDocument(super.caller);

  @override
  String get name => 'document';

  _i2.Future<String> upload(
    String document,
    String documentName,
    String? documentVersion,
  ) =>
      caller.callServerEndpoint<String>(
        'document',
        'upload',
        {
          'document': document,
          'documentName': documentName,
          'documentVersion': documentVersion,
        },
      );
}

class _EndpointExample extends _i1.EndpointRef {
  _EndpointExample(super.caller);

  @override
  String get name => 'example';

  _i2.Future<String> hello(String name) => caller.callServerEndpoint<String>(
        'example',
        'hello',
        {'name': name},
      );
}

class _EndpointMempoolTransactions extends _i1.EndpointRef {
  _EndpointMempoolTransactions(super.caller);

  @override
  String get name => 'mempoolTransactions';

  _i2.Future<List<_i12.TransactionView>> get({
    String? symbol,
    int? backFromHeight,
    required String chainName,
    required List<String> xpubkeys,
    required List<_i11.ByteData> h160s,
  }) =>
      caller.callServerEndpoint<List<_i12.TransactionView>>(
        'mempoolTransactions',
        'get',
        {
          'symbol': symbol,
          'backFromHeight': backFromHeight,
          'chainName': chainName,
          'xpubkeys': xpubkeys,
          'h160s': h160s,
        },
      );
}

class _EndpointBroadcastTransaction extends _i1.EndpointRef {
  _EndpointBroadcastTransaction(super.caller);

  @override
  String get name => 'broadcastTransaction';

  _i2.Future<_i13.CommString> get({
    required String rawTransactionHex,
    required String chainName,
  }) =>
      caller.callServerEndpoint<_i13.CommString>(
        'broadcastTransaction',
        'get',
        {
          'rawTransactionHex': rawTransactionHex,
          'chainName': chainName,
        },
      );
}

class _EndpointSubscription extends _i1.EndpointRef {
  _EndpointSubscription(super.caller);

  @override
  String get name => 'subscription';
}

class _EndpointTransactionDetails extends _i1.EndpointRef {
  _EndpointTransactionDetails(super.caller);

  @override
  String get name => 'transactionDetails';

  _i2.Future<_i14.TransactionDetailsView> get({
    required _i11.ByteData hash,
    required String chainName,
  }) =>
      caller.callServerEndpoint<_i14.TransactionDetailsView>(
        'transactionDetails',
        'get',
        {
          'hash': hash,
          'chainName': chainName,
        },
      );
}

class _EndpointTransactions extends _i1.EndpointRef {
  _EndpointTransactions(super.caller);

  @override
  String get name => 'transactions';

  _i2.Future<List<_i12.TransactionView>> get({
    String? symbol,
    int? backFromHeight,
    required String chainName,
    required List<String> xpubkeys,
    required List<_i11.ByteData> h160s,
  }) =>
      caller.callServerEndpoint<List<_i12.TransactionView>>(
        'transactions',
        'get',
        {
          'symbol': symbol,
          'backFromHeight': backFromHeight,
          'chainName': chainName,
          'xpubkeys': xpubkeys,
          'h160s': h160s,
        },
      );
}

class _EndpointUnsignedTransaction extends _i1.EndpointRef {
  _EndpointUnsignedTransaction(super.caller);

  @override
  String get name => 'unsignedTransaction';

  _i2.Future<_i5.UnsignedTransactionResult> completeAtomicSwap({
    required _i15.PartiallySignedTransactionRequest request,
    required String chainName,
  }) =>
      caller.callServerEndpoint<_i5.UnsignedTransactionResult>(
        'unsignedTransaction',
        'completeAtomicSwap',
        {
          'request': request,
          'chainName': chainName,
        },
      );

  _i2.Future<List<_i5.UnsignedTransactionResult>> generateUnsignedTransaction({
    required _i16.UnsignedTransactionRequest request,
    required String chainName,
  }) =>
      caller.callServerEndpoint<List<_i5.UnsignedTransactionResult>>(
        'unsignedTransaction',
        'generateUnsignedTransaction',
        {
          'request': request,
          'chainName': chainName,
        },
      );
}

class Client extends _i1.ServerpodClient {
  Client(
    String host, {
    _i17.SecurityContext? context,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
  }) : super(
          host,
          _i18.Protocol(),
          //context: context,
          authenticationKeyManager: authenticationKeyManager,
        ) {
    addresses = _EndpointAddresses(this);
    metadata = _EndpointMetadata(this);
    createAsset = _EndpointCreateAsset(this);
    reissueAsset = _EndpointReissueAsset(this);
    freezeRestrictedAsset = _EndpointFreezeRestrictedAsset(this);
    tagAddress = _EndpointTagAddress(this);
    balances = _EndpointBalances(this);
    circulatingSats = _EndpointCirculatingSats(this);
    consent = _EndpointConsent(this);
    hasGiven = _EndpointHasGiven(this);
    document = _EndpointDocument(this);
    example = _EndpointExample(this);
    mempoolTransactions = _EndpointMempoolTransactions(this);
    broadcastTransaction = _EndpointBroadcastTransaction(this);
    subscription = _EndpointSubscription(this);
    transactionDetails = _EndpointTransactionDetails(this);
    transactions = _EndpointTransactions(this);
    unsignedTransaction = _EndpointUnsignedTransaction(this);
  }

  late final _EndpointAddresses addresses;

  late final _EndpointMetadata metadata;

  late final _EndpointCreateAsset createAsset;

  late final _EndpointReissueAsset reissueAsset;

  late final _EndpointFreezeRestrictedAsset freezeRestrictedAsset;

  late final _EndpointTagAddress tagAddress;

  late final _EndpointBalances balances;

  late final _EndpointCirculatingSats circulatingSats;

  late final _EndpointConsent consent;

  late final _EndpointHasGiven hasGiven;

  late final _EndpointDocument document;

  late final _EndpointExample example;

  late final _EndpointMempoolTransactions mempoolTransactions;

  late final _EndpointBroadcastTransaction broadcastTransaction;

  late final _EndpointSubscription subscription;

  late final _EndpointTransactionDetails transactionDetails;

  late final _EndpointTransactions transactions;

  late final _EndpointUnsignedTransaction unsignedTransaction;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'addresses': addresses,
        'metadata': metadata,
        'createAsset': createAsset,
        'reissueAsset': reissueAsset,
        'freezeRestrictedAsset': freezeRestrictedAsset,
        'tagAddress': tagAddress,
        'balances': balances,
        'circulatingSats': circulatingSats,
        'consent': consent,
        'hasGiven': hasGiven,
        'document': document,
        'example': example,
        'mempoolTransactions': mempoolTransactions,
        'broadcastTransaction': broadcastTransaction,
        'subscription': subscription,
        'transactionDetails': transactionDetails,
        'transactions': transactions,
        'unsignedTransaction': unsignedTransaction,
      };
  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
