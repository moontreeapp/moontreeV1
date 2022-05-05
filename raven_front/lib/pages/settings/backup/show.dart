import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';

class BackupSeed extends StatefulWidget {
  final dynamic data;
  const BackupSeed({this.data}) : super();

  @override
  _BackupSeedState createState() => _BackupSeedState();
}

class _BackupSeedState extends State<BackupSeed>
    with SingleTickerProviderStateMixin {
  bool validated = true;
  bool warn = true;
  late double buttonWidth;
  late List<String> secret;
  TextEditingController existingPassword = TextEditingController();
  FocusNode existingFocus = FocusNode();
  FocusNode showFocus = FocusNode();
  ScreenshotCallback screenshotCallback = ScreenshotCallback();

  /// from exploring animations - want to return to
  //late AnimationController controller;
  //late Animation<double> animation;
  //late Animation<double> curve;
  //Offset offset = Offset(0.0, -1.0);
  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      screenshotCallback.addListener(() {
        // maybe we can repaint the screen real quick before the screenshot is taken
        // or display a message telling them to write it down...
        print('detect screenshot');
      });
    }

    /// from exploring animations - want to return to
    //controller = AnimationController(
    //    vsync: this, duration: Duration(milliseconds: 2400));
    //animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    //curve = CurvedAnimation(parent: animation, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      screenshotCallback.dispose();
    }

    /// from exploring animations - want to return to
    //controller.dispose();
    existingPassword.dispose();
    existingFocus.dispose();
    showFocus.dispose();
    super.dispose();
  }

  bool get passwordCondition =>
      services.password.required && services.cipher.canAskForPasswordNow;

  @override
  Widget build(BuildContext context) {
    buttonWidth = (MediaQuery.of(context).size.width - (17 + 17 + 16 + 16)) / 3;
    secret = Current.wallet.secret(Current.wallet.cipher!).split(' ');
    return body();
  }

  Widget body() => BackdropLayers(
      back: BlankBack(),
      front: FrontCurve(
          child: warn
              ? components.page.form(
                  context,
                  columnWidgets: <Widget>[
                    intro,
                    safe,
                    SizedBox(height: .2.ofMediaHeight(context)),
                    if (passwordCondition) login,
                  ],
                  buttons: [showButton],
                )
              : components.page.form(
                  context,
                  columnWidgets: <Widget>[
                    instructions,
                    warning,
                    words,
                  ],
                  buttons: [submitButton],
                )));

  /// from exploring animations - want to return to
  /// animate()
  //Widget animate(child) => SlideTransition(
  //    position: Tween<Offset>(
  //      begin: offset,
  //      end: Offset.zero,
  //    ).animate(curve),
  //    child: FadeTransition(opacity: animation, child: child));

  Widget get intro => Container(
      height: 48,
      alignment: Alignment.topCenter,
      child: Text(
        'Your wallet is valuable.\nPlease create a backup!',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.black),
      ));

  Widget get safe => Container(
      height: 48,
      alignment: Alignment.topCenter,
      child: Text(
        'You are about to backup your seed words.\nKeep it secret, keep it safe.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.error),
      ));

  Widget get instructions => Container(
      height: 48,
      alignment: Alignment.topCenter,
      child: Text(
        'Please backup your wallet by writing down these words on a piece of paper.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.black),
      ));

  Widget get warning => Container(
      height: 48,
      alignment: Alignment.topCenter,
      child: Text(
        'You will need these words for recovery.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.error),
      ));

  Widget get login => TextField(
        focusNode: existingFocus,
        autocorrect: false,
        enabled: passwordCondition ? true : false,
        controller: existingPassword,
        obscureText: true,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textField(
          context,
          focusNode: existingFocus,
          labelText: 'Password',
          errorText:
              existingPassword.text != '' && !verify() ? 'not match' : null,
        ),
        onChanged: (String value) {},
        onEditingComplete: () {
          if (verify()) {
            setState(() {});
          }
          setState(() {});
          FocusScope.of(context).requestFocus(showFocus);
        },
      );

  Widget get words => Container(
      height: MediaQuery.of(context).size.height - 444,
      alignment: Alignment.bottomCenter,
      child: Container(
          height: 272,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var x in [0, 3, 6, 9])
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i in [1, 2, 3])
                          components.buttons.wordButton(context,
                              width: buttonWidth,
                              chosen: false,
                              label: secret[(i + x) - 1],
                              onPressed: () {},
                              number: i + x)
                      ]),
              ])));

  bool verify() => services.password.validate.password(existingPassword.text);

  Widget get showButton => components.buttons.actionButton(context,
      enabled: passwordCondition ? verify() : true,
      label: 'Show Seed',
      focusNode: showFocus,
      onPressed: () => setState(() {
            warn = false;

            /// from exploring animations - want to return to
            //controller.forward();
          }));

  Widget get submitButton => components.buttons.actionButton(
        context,
        enabled: true,
        label: 'Next',
        link: '/security/backupConfirm',

        /// from exploring animations - want to return to
        //onPressed: () async {
        //  // change animation...
        //  animation = Tween(begin: 1.0, end: 0.0).animate(controller);
        //  curve = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        //  offset = Offset(0.0, 0.5);
        //  controller.reset();
        //  controller.forward();
        //  // wait the approapriate amount of time for the animation to play
        //  await Future.delayed(Duration(milliseconds: 2400));
        //},
      );
}
