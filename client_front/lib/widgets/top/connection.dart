import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/theme/theme.dart';
import 'package:client_front/widgets/front/choices/blockchain_choice.dart'
    show produceBlockchainModal;

class ConnectionLight extends StatefulWidget {
  const ConnectionLight({Key? key}) : super(key: key);

  @override
  _ConnectionLightState createState() => _ConnectionLightState();
}

class _ConnectionLightState extends State<ConnectionLight>
    with TickerProviderStateMixin {
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  Color connectionStatusColor = AppColors.error;
  Map<ConnectionStatus, Color> connectionColor = <ConnectionStatus, Color>{
    ConnectionStatus.connected: AppColors.success,
    ConnectionStatus.connecting: AppColors.yellow,
    ConnectionStatus.disconnected: AppColors.error,
  };
  /* alternative */
  bool connectionBusy = false;
  /* blinking animations */
  //bool busy = false;

  /* fancy movement animations
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
      duration: const Duration(milliseconds: durationH),
      vsync: this,
    );
    _controllerH.value = .5;
    _controllerH.repeat(reverse: true);
    _controllerV = AnimationController(
      duration: const Duration(milliseconds: durationV),
      vsync: this,
    );
    _controllerV.value = .5;
    _controllerV.repeat(reverse: true);
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
  }*/

  @override
  void initState() {
    super.initState();
    listeners.add(streams.client.connected.listen((ConnectionStatus value) {
      if (value != connectionStatus) {
        setState(() {
          connectionStatus = value;
          connectionStatusColor = connectionColor[value]!;
        });
      }
    }));
    listeners.add(streams.client.busy.listen((bool value) async {
      if (value != connectionBusy) {
        setState(() => connectionBusy = value);
      }

      /* blinking animations */
      //if (value && !connectionBusy) {
      //  setState(() => connectionBusy = value);
      //  //rebuildMe();
      //}
      //if (!value && connectionBusy) {
      //  setState(() => connectionBusy = value);
      //}
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  /* blinking animations */
  //Future<void> rebuildMe() async {
  //  await Future<void>.delayed(const Duration(milliseconds: 600));
  //  if (connectionBusy) {
  //    // don't blink when spinner runs... separate into different streams?
  //    if (!['Login', 'Createlogin'].contains(streams.app.page.value) &&
  //        !services.wallet.leader.newLeaderProcessRunning) {
  //      setState(() => busy = !busy);
  //    }
  //    rebuildMe();
  //  } else {
  //    if (busy) {
  //      setState(() => busy = !busy);
  //    }
  //  }
  //}

  @override
  Widget build(BuildContext context) {
    final AnimatedContainer circleIcon = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
    );
    return GestureDetector(
      onTap: navToBlockchain,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        alignment: Alignment.center,
        padding: EdgeInsets.zero,
        child: pros.settings.chain == Chain.none
            ? IconButton(
                splashRadius: 26,
                padding: EdgeInsets.zero,
                icon: circleIcon,
                onPressed: navToBlockchain,
              )
            : Stack(alignment: Alignment.center, children: <Widget>[
                ColorFiltered(
                    colorFilter: ColorFilter.mode(statusColor, BlendMode.srcIn),
                    child: components.icons.assetAvatar(
                      pros.settings.chain.symbol,
                      net: pros.settings.net,
                      height: 26,
                      width: 26,
                    )),
                components.icons.assetAvatar(pros.settings.chain.symbol,
                    net: pros.settings.net, height: 24, width: 24),
              ]),
      ),
    );
  }

  Color get statusColor => connectionStatus == ConnectionStatus.connected &&
          connectionBusy // && busy
      ? AppColors.logoGreen
      : connectionStatusColor;

  void navToBlockchain() {
    if (streams.app.scrim.value ?? false) {
      return;
    }
    if (streams.app.loading.value == true) {
      return;
    }
    if (!<String>[
      'Login',
      'Createlogin',
      'Network',
      'Scan',
      'Setup',
      'Backupintro',
      'Backupconfirm',
      'Backup',
    ].contains(streams.app.page.value)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      streams.app.lead.add(LeadIcon.dismiss);
      produceBlockchainModal(components.routes.routeContext!);
      //Navigator.of(components.routes.routeContext!)
      //    .pushNamed('/settings/network/blockchain');
    }
  }
}

class SpoofedConnectionLight extends StatelessWidget {
  const SpoofedConnectionLight({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color connectionStatusColor = AppColors.success;
    final ColorFiltered icon = ColorFiltered(
        colorFilter:
            const ColorFilter.mode(connectionStatusColor, BlendMode.srcATop),
        child: SvgPicture.asset('assets/status/icon.svg'));
    return IconButton(
      splashRadius: 24,
      padding: EdgeInsets.zero,
      onPressed: () {},
      icon: icon,
    );
  }
}