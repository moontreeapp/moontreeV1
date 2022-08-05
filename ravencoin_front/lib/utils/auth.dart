import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
// ignore: unused_import
import 'package:ravencoin_back/services/consent.dart';
import 'package:ravencoin_front/components/components.dart';

Future logout() async {
  pros.ciphers.clear();
  streams.app.setting.add(null);
  Navigator.pushReplacementNamed(
    components.navigator.routeContext!,
    '/security/login',
  );
  streams.app.splash.add(false);
}