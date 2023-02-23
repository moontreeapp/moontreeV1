import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/infrastructure/services/wallet.dart'
    show populateWalletsWithSensitives, saveSecret, setupWallets;
import 'package:client_back/services/consent.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/theme/extensions.dart';
import 'package:client_front/domain/utils/device.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/domain/utils/login.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginCreatePassword extends StatefulWidget {
  const LoginCreatePassword({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('LoginCreatePassword');
  @override
  _LoginCreatePasswordState createState() => _LoginCreatePasswordState();
}

class _LoginCreatePasswordState extends State<LoginCreatePassword> {
  //late List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  TextEditingController password = TextEditingController();
  TextEditingController confirm = TextEditingController();
  bool passwordVisible = false;
  bool confirmVisible = false;
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmFocus = FocusNode();
  FocusNode unlockFocus = FocusNode();
  bool noPassword = true;
  String? passwordText;
  bool consented = false;
  bool isConsented = false;
  final int minimumLength = 1;

  @override
  void initState() {
    super.initState();
    //listeners.add(streams.password.exists.listen((bool value) {
    //  if (value && noPassword) {
    //    noPassword = false;
    //    //exitProcess();
    //  }
    //}));
  }

  @override
  void dispose() {
    //for (final StreamSubscription<dynamic>> listener in listeners) {
    //  listener.cancel();
    //}
    password.dispose();
    confirm.dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    unlockFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: const BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: [
                    Container(
                        alignment: Alignment.bottomCenter,
                        height: .242.ofMediaHeight(context),
                        child: moontree),
                    SizedBox(height: .01.ofMediaHeight(context)),
                    Container(
                        alignment: Alignment.bottomCenter,
                        height: .035.ofMediaHeight(context),
                        child: welcomeMessage),
                    SizedBox(
                      height: .0789.ofMediaHeight(context),
                    ),
                    Container(
                        alignment: Alignment.topCenter,
                        // height: 76,
                        height: .0947.ofMediaHeight(context),
                        child: passwordField),
                    Container(
                        alignment: Alignment.topCenter,
                        // height: 76 + 16,
                        height: .0947.ofMediaHeight(context),
                        child: confirmField),
                    SizedBox(height: 16),
                    Container(
                      alignment: Alignment.topCenter,
                      child: components.text.passwordWarning,
                    ),
                  ],
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 16,
                      ),
                      ulaMessage,
                      SizedBox(
                        height: 16,
                      ),
                      Row(children: <Widget>[unlockButton]),
                      SizedBox(
                        height: 40,
                      ),
                    ]),
              ])));

  Widget get moontree => Container(
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
        height: .1534.ofMediaHeight(context),
        // height: 110.figma(context),
      );

  Widget get welcomeMessage => Text('Moontree',
      style: Theme.of(context)
          .textTheme
          .headline1
          ?.copyWith(color: AppColors.black60));

  Widget get ulaMessage => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
              alignment: Alignment.center, width: 18, child: aggrementCheckbox),
          Container(
              alignment: Alignment.center,
              width: .70.ofMediaWidth(context),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(components.routes.routeContext!)
                      .textTheme
                      .bodyText2,
                  children: <TextSpan>[
                    const TextSpan(text: "I agree to Moontree's\n"),
                    TextSpan(
                        text: 'User Agreement',
                        style: Theme.of(components.routes.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.user_agreement)));
                          }),
                    const TextSpan(text: ', '),
                    TextSpan(
                        text: 'Privacy Policy',
                        style: Theme.of(components.routes.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.privacy_policy)));
                          }),
                    const TextSpan(text: ',\n and '),
                    TextSpan(
                        text: 'Risk Disclosure',
                        style: Theme.of(components.routes.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.risk_disclosures)));
                          }),
                  ],
                ),
              )),
          const SizedBox(
            width: 18,
          ),
        ],
      );

  Widget get passwordField => TextFieldFormatted(
      onTap: () => setState(() {}),
      focusNode: passwordFocus,
      autocorrect: false,
      controller: password,
      obscureText: !passwordVisible,
      textInputAction: TextInputAction.next,
      labelText: 'Password',
      errorText: password.text != '' && password.text.length < minimumLength
          ? 'password must be at least $minimumLength characters long'
          : null,
      helperText: !(password.text != '' && password.text.length < minimumLength)
          ? ''
          : null,
      suffixIcon: IconButton(
        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.black60),
        onPressed: () => setState(() {
          passwordVisible = !passwordVisible;
        }),
      ),
      onChanged: (_) => setState(() {}),
      onEditingComplete: () {
        setState(() {});
        if (password.text != '' && password.text.length >= minimumLength) {
          FocusScope.of(context).requestFocus(confirmFocus);
        }
      });

  Widget get confirmField => TextFieldFormatted(
      onTap: () => setState(() {}),
      focusNode: confirmFocus,
      autocorrect: false,
      controller: confirm,
      obscureText: !confirmVisible, // masked controller for immediate?
      textInputAction: TextInputAction.done,
      labelText: 'Confirm Password',
      errorText: confirm.text != '' && confirm.text != password.text
          ? 'does not match password'
          : null,
      helperText: confirm.text == password.text ? 'match' : null,
      suffixIcon: IconButton(
        icon: Icon(confirmVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.black60),
        onPressed: () => setState(() {
          confirmVisible = !confirmVisible;
        }),
      ),
      onChanged: (_) => setState(() {}),
      onEditingComplete: () {
        setState(() {});
        if (confirm.text == password.text) {
          FocusScope.of(context).requestFocus(unlockFocus);
        }
      });

  bool isConnected() =>
      streams.client.connected.value == ConnectionStatus.connected;

  Widget get unlockButton => components.buttons.actionButton(context,
      enabled: isConnected() && validate(),
      focusNode: unlockFocus,
      label: passwordText == null ? 'Create Wallet' : 'Creating Wallet...',
      disabledOnPressed: () => setState(() {
            if (!isConnected()) {
              streams.app.snack.add(Snack(
                message: 'Unable to connect! Please check connectivity.',
              ));
            }
          }),
      onPressed: () async => submit());

  Widget get aggrementCheckbox => Checkbox(
        //checkColor: Colors.white,
        value: isConsented,
        onChanged: (bool? value) async {
          setState(() {
            isConsented = value!;
          });
        },
      );

  bool validate() {
    return passwordText == null &&
        password.text.length >= minimumLength &&
        confirm.text == password.text &&
        isConsented;
  }

  Future<void> consentToAgreements() async {
    // consent just once
    if (!consented) {
      final Consent consent = Consent();
      await consent.given(await getId(), ConsentDocument.user_agreement);
      await consent.given(await getId(), ConsentDocument.privacy_policy);
      await consent.given(await getId(), ConsentDocument.risk_disclosures);
      consented = true;
    }
  }

  Future<void> submit({bool showFailureMessage = true}) async {
    // since the concent calls take some time, maybe this should be removed...?
    if (validate()) {
      // only run once - disable button
      setState(() => passwordText = password.text);
      await services.authentication
          .setMethod(method: AuthMethod.moontreePassword);
      await consentToAgreements();
      //await Future<void>.delayed(const Duration(milliseconds: 200)); // in release mode?
      await populateWalletsWithSensitives();
      await services.authentication.setPassword(
        password: password.text,
        //salt: password.text, // we should salt it with the password itself...
        /// if we salt with this we must provide it to them for decrypting
        /// exports, which means since this is the way it already is, this will
        /// require a migration or a password reset before the export feature is
        /// made available... unless we don't encrypt exports...
        salt: await SecureStorage.authenticationKey,
        message: '',
        saveSecret: saveSecret,
      );
      await exitProcess();
    } else {
      setState(() {
        password.text = '';
      });
    }
  }

  Future<void> exitProcess() async {
    await components.loading.screen(
      message: 'Creating Wallet',
      returnHome: false,
      playCount: 4,
    );
    await setupWallets();
    login(context, password: password.text);
  }
}
