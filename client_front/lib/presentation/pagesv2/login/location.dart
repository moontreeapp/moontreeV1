import 'package:client_front/presentation/pagesv2/login/create.dart';
import 'package:client_front/presentation/pagesv2/login/create_native.dart';
import 'package:client_front/presentation/pagesv2/login/create_password.dart';
import 'package:client_front/presentation/pagesv2/login/native.dart';
import 'package:client_front/presentation/pagesv2/login/password.dart';
import 'package:client_front/presentation/pagesv2/login/splash.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:client_front/presentation/utilities/animation.dart';

class FrontLoginLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => [
        '/login/splash',
        '/login/create',
        '/login/create/native',
        '/login/create/password',
        '/login/native',
        '/login/password',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        if (state.uri.pathSegments.contains('splash'))
          const FadeTransitionPage(child: FrontSplashScreen()),
        if (state.uri.toString() == '/login/create')
          const FadeTransitionPage(child: FrontCreateScreen()),
        if (state.uri.toString() == '/login/create/native')
          const FadeTransitionPage(child: FrontCreateNativeScreen()),
        if (state.uri.toString() == '/login/create/password')
          const FadeTransitionPage(child: FrontCreatePasswordScreen()),
        if (state.uri.toString() == '/login/native')
          const FadeTransitionPage(child: FrontNativeScreen()),
        if (state.uri.toString() == '/login/password')
          const FadeTransitionPage(child: FrontPasswordScreen()),
      ];
}