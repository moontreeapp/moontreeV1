import 'package:magic/presentation/widgets/assets/icons.dart';
import 'package:magic/services/services.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:magic/utils/log.dart';

class Privacy extends StatefulWidget {
  final Widget child;

  const Privacy({
    super.key,
    required this.child,
  });

  @override
  State<Privacy> createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> with WidgetsBindingObserver {
  bool _isInBackground = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    see('is in background: $_isInBackground');
    switch (state) {
      case AppLifecycleState.resumed:
        if (_isInBackground) {
          setState(() {
            _isInBackground = false;
          });
          cubits.welcome.update(
            allowScreenshot: false,
          );
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        setState(() {
          _isInBackground = true;
        });
        cubits.welcome.update(
          allowScreenshot: true,
        );
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
    }
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isInBackground)
          Container(
            color: Colors.black,
            child: Center(
              child: SvgPicture.asset(
                LogoIcons.appLogo,
                height: screen.appbar.logoHeight * 6,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
      ],
    );
  }
}
