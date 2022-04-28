import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/client.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';

class ConnectionLight extends StatefulWidget {
  ConnectionLight({Key? key}) : super(key: key);

  @override
  _ConnectionLightState createState() => _ConnectionLightState();
}

class _ConnectionLightState extends State<ConnectionLight>
    with TickerProviderStateMixin {
  List<StreamSubscription> listeners = [];
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  Color connectionStatusColor = AppColors.error;
  bool connectionBusy = false;
  late DateTime startTime;
  final int durationV = 1236;
  final int durationH = 2000;

  late AnimationController _controllerH;
  late AnimationController _controllerV;
  late Animation<Offset> _offsetAnimationH;
  late Animation<Offset> _offsetAnimationV;

  Map<ConnectionStatus, Color> connectionColor = {
    ConnectionStatus.connected: AppColors.success,
    ConnectionStatus.connecting: AppColors.yellow,
    ConnectionStatus.disconnected: AppColors.error,
  };

  void createAnimations() {
    _controllerH = AnimationController(
      duration: Duration(milliseconds: durationH),
      vsync: this,
    )..repeat(reverse: true);
    _controllerV = AnimationController(
      duration: Duration(milliseconds: durationV),
      vsync: this,
    )..repeat(reverse: true);
    _offsetAnimationH = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controllerH,
      curve: Curves.easeInOut,
    ));
    _offsetAnimationV = Tween<Offset>(
      begin: const Offset(0, -.1),
      end: const Offset(0, .1),
    ).animate(CurvedAnimation(
      parent: _controllerV,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void initState() {
    super.initState();
    createAnimations();
    listeners.add(streams.client.connected.listen((ConnectionStatus value) {
      if (value != connectionStatus) {
        setState(() {
          connectionStatus = value;
          connectionStatusColor = connectionColor[value]!;
        });
      }
    }));
    listeners.add(streams.client.busy.listen((bool value) async {
      if (!connectionBusy && value) {
        setState(() => connectionBusy = value);
      } else if (connectionBusy && !value) {
        if (streams.client.busy.value == value) {
          setState(() => connectionBusy = value);
        }
      }
    }));
  }

  @override
  void dispose() {
    _controllerH.dispose();
    _controllerV.dispose();
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var icon = ColorFiltered(
        colorFilter: ColorFilter.mode(connectionStatusColor, BlendMode.srcATop),
        child: SvgPicture.asset('assets/status/icon.svg'));
    return connectionBusy
        ? GestureDetector(
            onTap: () => streams.client.busy.add(false),
            child:

                /// you might like this
                //SlideTransition(
                //    position: _offsetAnimationH,
                //    child: SlideTransition(
                //      position: _offsetAnimationV,
                //      child: icon,
                //    ))
                // needs a transparent background
                Container(
                    width: 36,
                    alignment: Alignment.centerLeft,
                    child: Lottie.asset(
                      'assets/spinner/moontree_spinner_v2_002_1_recolored.json',
                      animate: true,
                      repeat: true,
                      width: 56 / 2,
                      height: 56 / 2,
                      alignment: Alignment.centerLeft,
                    )),
          )
        : Container(
            alignment: Alignment.center,
            child: IconButton(
              splashRadius: 24,
              padding: EdgeInsets.zero,
              onPressed: () {
                if (streams.app.page.value != 'Login') {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  if (services.cipher.canAskForPasswordNow) {
                    streams.app.verify.add(false);
                  }
                  streams.app.xlead.add(true);
                  Navigator.of(components.navigator.routeContext!)
                      .pushNamed('/settings/network');
                }
              },
              icon: icon,
            ));
  }
}

class SpoofedConnectionLight extends StatelessWidget {
  SpoofedConnectionLight({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color connectionStatusColor = AppColors.success;
    var icon = ColorFiltered(
        colorFilter: ColorFilter.mode(connectionStatusColor, BlendMode.srcATop),
        child: SvgPicture.asset('assets/status/icon.svg'));
    return IconButton(
      splashRadius: 24,
      padding: EdgeInsets.zero,
      onPressed: () {},
      icon: icon,
    );
  }
}
