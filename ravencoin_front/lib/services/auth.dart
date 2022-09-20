import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ravencoin_front/services/storage.dart';

enum AuthenticationResult {
  success,
  failure,
  noSupport,
  notSetup,
  noBiometrics,
  error,
}

class LocalAuthApi {
  final _auth = LocalAuthentication();
  AuthenticationResult? reason;

  Future<bool> get canCheckBiometrics async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      return false;
    }
  }

  /// this name seems misleading "isDeviceSupported"
  /// Returns false if no biometric is setup, true if it is...
  Future<bool> get isSetup async => await _auth.isDeviceSupported();

  Future<List<BiometricType>> get availableBiometrics async =>
      await _auth.getAvailableBiometrics();

  Future<bool> get readyToAuthenticate async {
    if (!await canCheckBiometrics) {
      reason = AuthenticationResult.noSupport;
      return false;
    }
    //if (!await isSetup) {
    //  reason = AuthenticationResult.notSetup;
    //  return false;
    //}
    //List<BiometricType> biometrics = await availableBiometrics;
    //if (biometrics.isEmpty) {
    //  reason = AuthenticationResult.noBiometrics;
    //  return false;
    //}
    return true;
  }

  Future<bool> authenticate({bool stickyAuth = false}) async {
    if (!(await readyToAuthenticate)) {
      return false;
    }

    // Some biometrics are enrolled.
    //if (biometrics.contains(BiometricType.strong) ||
    //    biometrics.contains(BiometricType.face)) {
    //  // Specific types of biometrics are available.
    //  // Use checks like this with caution!
    //}
    try {
      if (await _auth.authenticate(
        localizedReason: 'Please Authenticate',
        //Iterable<AuthMessages> authMessages = const <AuthMessages>[IOSAuthMessages(), AndroidAuthMessages(), WindowsAuthMessages()],
        //authMessages: const [
        //  AndroidAuthMessages(
        //    signInTitle: 'Oops! Biometric authentication required!',
        //    cancelButton: 'No thanks',
        //  ),
        //  IOSAuthMessages(
        //    cancelButton: 'No thanks',
        //  ),
        //],
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: false,
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      )) {
        reason = AuthenticationResult.success;
        return true;
      }
      reason = AuthenticationResult.failure;
    } on PlatformException catch (e) {
      /*
      Whether the system will attempt to handle user-fixable issues encountered
      while authenticating. For instance, if a fingerprint reader exists on the
      device but there's no fingerprint registered, the plugin might attempt to
      take the user to settings to add one. Anything that is not user fixable,
      such as no biometric sensor on device, will still result in a
      [PlatformException].
      (Therefore we should fall back on the password posibility.)
      */
      print(e);
      reason = AuthenticationResult.error;
    }
    return false;
  }
}
