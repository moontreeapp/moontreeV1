/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class Wallet extends _i1.SerializableEntity {
  Wallet({
    this.id,
    required this.publicKey,
  });

  factory Wallet.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Wallet(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      publicKey: serializationManager
          .deserialize<String>(jsonSerialization['publicKey']),
    );
  }

  int? id;

  String publicKey;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicKey': publicKey,
    };
  }
}
