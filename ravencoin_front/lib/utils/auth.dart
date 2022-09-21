import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
// ignore: unused_import
import 'package:ravencoin_back/services/consent.dart';
import 'package:ravencoin_front/components/components.dart';

Future logout() async {
  pros.ciphers.clear();
  streams.app.setting.add(null);
  //streams.app.logout.add(true); // notify the login page not to auto-ask
  Navigator.pushReplacementNamed(
      components.navigator.routeContext!, getMethodPathLogin(),
      arguments: {'autoInitiateUnlock': false});
  streams.app.splash.add(false);
}

String getMethodPathLogin() => pros.settings.authMethodIsBiometric
    ? '/security/biometric/login'
    : '/security/password/login';

String getMethodPathCreate() => pros.settings.authMethodIsBiometric
    ? '/security/biometric/createlogin'
    : '/security/password/createlogin';
