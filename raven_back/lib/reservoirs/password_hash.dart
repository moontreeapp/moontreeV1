import 'package:collection/collection.dart';
import 'package:raven/records/password_hash.dart';
import 'package:reservoir/reservoir.dart';
import 'package:quiver/iterables.dart';

part 'password_hash.keys.dart';

class PasswordHashReservoir extends Reservoir<_IdKey, PasswordHash> {
  PasswordHashReservoir() : super(_IdKey());

  int maxPasswordID() =>
      max([for (var passwordHash in data) passwordHash.passwordId]) ?? 0;

  //String salt() => passwordHashes...?

}
