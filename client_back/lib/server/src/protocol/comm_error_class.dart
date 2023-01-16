/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class EndpointError extends _i1.SerializableEntity {
  EndpointError({
    this.id,
    required this.value,
  });

  factory EndpointError.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return EndpointError(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      value:
          serializationManager.deserialize<String>(jsonSerialization['value']),
    );
  }

  int? id;

  String value;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
    };
  }
}
