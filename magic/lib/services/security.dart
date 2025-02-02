import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:magic/domain/storage/secure.dart';
import 'package:magic/services/services.dart' show secureStorage;
import 'package:magic/presentation/widgets/other/app_dialog.dart';
import 'package:magic/utils/logger.dart';

class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _noScreenshot = NoScreenshot.instance;

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> isAuthenticationPresent() async {
    try {
      List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty ||
          await _localAuth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticateUser({bool? canCheckBio, bool? isAuthSetup}) async {
    canCheckBio = canCheckBio ?? await canCheckBiometrics();
    isAuthSetup = isAuthSetup ?? await isAuthenticationPresent();
    //print('canCheckBio: $canCheckBio, isAuthSetup: $isAuthSetup');
    //print(await _localAuth.getAvailableBiometrics());
    //print(await _localAuth.isDeviceSupported());
    if (Platform.isAndroid && (!canCheckBio || !isAuthSetup)) {
      // Device doesn't support biometrics or auth is not set up
      return true;
    } else if (Platform.isIOS && (!canCheckBio && !isAuthSetup)) {
      // Device doesn't support biometrics or auth is not set up
      return true;
    } else if (Platform.isIOS && !isAuthSetup) {
      // Device Device doesn't have biometrics or auth set up
      return true;
    }

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        //options: const AuthenticationOptions(
        //  stickyAuth: true,
        //  biometricOnly: false,
        //),
      );
      if (authenticated) {
        await _setUserAuthenticated();
      }
      return authenticated;
    } on PlatformException catch (e) {
      logD(e);
      return false;
    }
  }

  Future<bool> hasUserAuthenticated() async =>
      await secureStorage.read(key: SecureStorageKey.authed.key()) == 'true';

  Future<void> _setUserAuthenticated() async => await secureStorage.write(
      key: SecureStorageKey.authed.key(), value: 'true');

  Future<void> clearAuthentication() async =>
      await secureStorage.delete(key: SecureStorageKey.authed.key());

  Future<bool> checkUSBDebuggingStatus(BuildContext context) async {
    if (Platform.isAndroid) {
      const platform = MethodChannel('usb_debug_check');
      try {
        final bool isEnabled =
            await platform.invokeMethod('isUSBDebuggingEnabled');
        if (isEnabled && context.mounted) {
          showUSBDebuggingWarningDialog(context);
          return true;
        }
        return false;
      } on PlatformException catch (e) {
        logD("Failed to check USB Debugging: '${e.message}'.");
        return false;
      }
    }
    return false;
  }

  Future<bool> disableScreenshot() async {
    bool result = await _noScreenshot.screenshotOff();
    logD('Screenshot Off: $result');
    return result;
  }

  Future<bool> enableScreenshot() async {
    bool result = await _noScreenshot.screenshotOn();
    logD('Enable Screenshot: $result');
    return result;
  }
}

final securityService = SecurityService();
