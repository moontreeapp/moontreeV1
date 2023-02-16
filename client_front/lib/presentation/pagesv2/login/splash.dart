import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/infrastructure/services/password.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/domain/utils/device.dart';
import 'package:client_front/presentation/widgets/backdrop/backdrop.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/services.dart';
import 'package:client_back/services/consent.dart';

class FrontSplashScreen extends StatelessWidget {
  const FrontSplashScreen({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('frontLoginSplash');

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16),
            height: 56,
            child: const Text(
              style: TextStyle(color: Colors.black),
              'some example setting thing',
            ),
          ),
        ],
      ),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  BorderRadius? shape;
  bool showAppBar = false;

  final Duration animationDuration = const Duration(milliseconds: 1000);
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late final Animation<double> _fadeAnimation =
      Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);
  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: Offset(0, 56 / MediaQuery.of(context).size.height),
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeInOut,
  ));

  @override
  void initState() {
    super.initState();
    _slideController =
        AnimationController(vsync: this, duration: animationDuration);
    _fadeController =
        AnimationController(vsync: this, duration: animationDuration);
    _init();
  }

  Future<void> _init() async {
    await Future<void>.delayed(const Duration(milliseconds: 3500));
    await HIVE_INIT.setupDatabaseStart();
    await HIVE_INIT.setupDatabase1();

    /// update version right after we open settings box, capture a snapshot of
    /// the movement if we need to use it for migration logic:
    services.version.rotate(
      services.version.byPlatform(Platform.isIOS ? 'ios' : 'android'),
    );

    /// must use a heavier isolate implementation
    //compute((_) async {

    // put here or on login screen. here seems better for now.
    await HIVE_INIT.setupWaiters1();
    await services.client.createClient();
    await HIVE_INIT.setupDatabase2();
    await HIVE_INIT.setupWaiters2();

    //}, null);

    await Future<void>.delayed(const Duration(milliseconds: 1));
    setState(() {
      shape = components.shape.topRoundedBorder8;
    });
    _fadeController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    //await Future<void>.delayed(const Duration(milliseconds: 1000));
    //_slideController.forward();
    //// hack to trigger animate Welcome
    //streams.app.loading.add(false);
    //streams.app.loading.add(true);
    //streams.app.loading.add(false);
    //await Future<void>.delayed(const Duration(milliseconds: 1000));
    //_fadeController.forward();
    //await Future<void>.delayed(const Duration(milliseconds: 1000));
    //setState(() {
    //  _slideController.reset();
    //  showAppBar = true;
    //});
    await redirectToCreateOrLogin();
    streams.app.splash.add(false);
    //await HIVE_INIT.setupWaiters1(); // if you put on login screen
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.androidSystemBar,
      appBar: showAppBar
          ? BackdropAppBarContents(spoof: true, animate: false)
          : null,
      body:
          /**/
          Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          if (!showAppBar) BackdropAppBarContents(spoof: true),
          SlideTransition(
              position: _slideAnimation,
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(borderRadius: shape, color: Colors.white),
                  child: FadeTransition(
                      opacity: _fadeAnimation,
                      child:
                          /**/
                          Lottie.asset(
                              'assets/splash/moontree_v2_001_recolored.json',
                              animate: true,
                              repeat: false,
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover
                              /**/
                              ))))
        ],
        /**/
      ),
    );
  }

  Future<void> redirectToCreateOrLogin() async {
    //Future passwordFallback() async {
    //  services.authentication.setMethod(method: AuthMethod.moontreePassword);
    //  Future.microtask(() => Navigator.pushReplacementNamed(
    //        context,
    //        getMethodPathCreate(),
    //      ));
    //}

    // make a password out of biokey

    // this is false on 1st startup -> create
    if (!services.password.required) {
      //streams.app.page.add('Setup');
      Future<void>.microtask(() => Navigator.pushReplacementNamed(
            context,
            '/security/create/setup',
          ));
      //if (pros.settings.authMethodIsNativeSecurity) {
      //  final localAuthApi = LocalAuthApi();
      //  if (await localAuthApi.readyToAuthenticate) {
      //    Future.microtask(() => Navigator.pushReplacementNamed(
      //        context, getMethodPathCreate(),
      //        arguments: {'needsConsent': true}));
      //  } else {
      //    passwordFallback();
      //  }
      //} else {
      //  passwordFallback();
      //}
    } else {
      await maybeSwitchToPassword();
      if (services.password.interruptedPasswordChange()) {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                    title: const Text('Issue detected'),
                    content: const Text(
                        'Change Password process in progress, please submit your previous password...'),
                    actions: <Widget>[
                      TextButton(
                          child: const Text('ok'),
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/security/resume',
                              arguments: <String, dynamic>{}))
                    ]));
      } else {
        bool hasConsented = false;
        try {
          hasConsented = await discoverConsent(await getId());
        } catch (e) {
          streams.app.snack.add(Snack(
            message: 'Unable to connect! Please check connectivity.',
          ));
        }
        Future<void>.microtask(() => Navigator.pushReplacementNamed(
            context, getMethodPathLogin(),
            arguments: <String, bool>{'needsConsent': !hasConsented}));

        /// testing out instant/custom page transitions
        /// https://stackoverflow.com/questions/52698340/animation-for-named-routes
        //    Navigator.of(components.routes.routeContext!)
        //        .push(PageRouteBuilder(
        //  pageBuilder: (_, __, ___) => pages.routes(
        //          components.routes.routeContext!)['/security/login']!(
        //      components.routes.routeContext!),
        //  transitionsBuilder: (_, a, __, c) => c,
        //  transitionDuration: Duration(milliseconds: 0),
        //)));
      }
    }

    /// old: send to homescreen
    //} else {
    //Futuredelayed(const Duration(seconds: 60));
    //  Future.microtask(() =>
    //      Navigator.pushReplacementNamed(context, '/home', arguments: {}));

    /// testing out instant/custom page transitions
    //Navigator.of(components.routes.routeContext!)
    //    .push(PageRouteBuilder(
    //  pageBuilder: (_, __, ___) =>
    //      pages.routes(components.routes.routeContext!)['/home']!(
    //          components.routes.routeContext!),
    //  transitionsBuilder: (_, a, __, c) =>
    //      FadeTransition(opacity: a, child: c),
    //  transitionDuration: Duration(milliseconds: 2000),
    //)));
    //}
  }
}