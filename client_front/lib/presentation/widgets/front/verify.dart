import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/styles/styles.dart'
    as styles;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/auth.dart';
import 'package:client_front/infrastructure/services/dev.dart';
import 'package:client_front/infrastructure/services/password.dart';
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class VerifyAuthentication extends StatefulWidget {
  final State? parentState;
  final String buttonLabel;
  final String? suffix;
  final Widget? intro;
  final Widget? safe;
  final bool auto;
  final bool asLoginTime;

  const VerifyAuthentication({
    Key? key,
    this.parentState,
    this.buttonLabel = 'Submit',
    this.suffix,
    this.intro,
    this.safe,
    this.auto = true,
    this.asLoginTime = true,
  }) : super(key: key);

  @override
  _VerifyAuthenticationState createState() => _VerifyAuthenticationState();
}

class _VerifyAuthenticationState extends State<VerifyAuthentication> {
  Map<String, dynamic> data = <String, dynamic>{};
  TextEditingController password = TextEditingController();
  bool passwordVisible = false;
  FocusNode existingFocus = FocusNode();
  FocusNode submitFocus = FocusNode();
  bool failedAttempt = false;
  bool enabled = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    password.dispose();
    existingFocus.dispose();
    submitFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      data = populateData(context, data);
    } catch (e) {
      data = <String, dynamic>{};
    }

    if (widget.auto &&
        pros.settings.authMethodIsNativeSecurity &&
        (data['autoInitiateUnlock'] as bool? ?? true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await submit();
      });
      data['autoInitiateUnlock'] = false;
    }

    //GestureDetector(
    //onTap: () => FocusScope.of(context).unfocus(),
    //child:
    return FrontCurve(
      child: components.page.form(
        context,
        columnWidgets: <Widget>[
          if (widget.intro != null) widget.intro!,
          Container(
              height: ((MediaQuery.of(context).size.height) -
                      (56 +
                          40 +
                          16 +
                          16 +
                          72.figma(context) +
                          (widget.intro != null ? 40.figma(context) : 0))) /
                  3),
          //Center(
          //    child: Text(
          //        'Please verify your password\nto proceed' +
          //            (widget.suffix != null ? ' ' + widget.suffix! : ''),
          //        textAlign: TextAlign.center,
          //        style: Theme.of(context).textTheme.bodyText1)),
          //SizedBox(height: 8),

          const LockedOutTime(),
          if (pros.settings.authMethodIsNativeSecurity)
            bioText
          else
            passwordField,
        ],
        buttons: <Widget>[
          if (pros.settings.authMethodIsNativeSecurity)
            bioButton
          else
            submitButton
        ],
      ),
      //)
    );
  }

  Widget get passwordField => TextField(
        focusNode: existingFocus,
        autocorrect: false,
        enabled: services.password.required ? true : false,
        controller: password,
        obscureText: !passwordVisible,
        textInputAction: TextInputAction.done,
        decoration: styles.decorations.textField(
          context,
          focusNode: existingFocus,
          labelText: 'Password',
          errorText: password.text == '' &&
                  pros.settings.loginAttempts.isNotEmpty &&
                  failedAttempt
              ? 'Incorrect Password'
              : null,
          //suffixIcon: IconButton(
          //  icon: Icon(
          //      passwordVisible
          //          ? Icons.visibility
          //          : Icons.visibility_off,
          //      color: AppColors.black60),
          //  onPressed: () => setState(() {
          //    passwordVisible = !passwordVisible;
          //  }),
          //),
        ),
        onEditingComplete: () {
          setState(() {});
          FocusScope.of(context).requestFocus(submitFocus);
        },
      );

  Widget get submitButton => components.buttons.actionButton(
        context,
        focusNode: submitFocus,
        enabled: password.text != '' && services.password.lockout.timePast(),
        label: data['buttonLabel'] as String? ?? widget.buttonLabel,
        onPressed: submitProceedure,
      );

  Future<bool> verify() async => services.password.validate.password(
        password: password.text,
        salt: await SecureStorage.authenticationKey,
        saltedHashedPassword: await getLatestSaltedHashedPassword(),
      ); // &&
  //services.password.validate.previouslyUsed(password.text) == 0;

  Future<void> submitProceedure() async {
    if (await services.password.lockout
        .handleVerificationAttempt(await verify())) {
      streams.app.verify.add(true);
      widget.parentState?.setState(() {});
      (data['onSuccess'] ?? () {})();
    } else {
      setState(() {
        failedAttempt = true;
        password.text = '';
      });
    }
  }

  String used() =>
      <int?, String>{
        null: 'unrecognized',
        //0: 'current password',
        //1: 'prior password',
        //2: 'password before last',
      }[services.password.validate.previouslyUsed(password.text)] ??
      //'has been used before';
      'unrecognized';

  Widget get bioText => Container(
      alignment: Alignment.center,
      child: Text('Please Authenticate',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              ?.copyWith(color: AppColors.primary)));

  Widget get bioButton => components.buttons.actionButton(
        context,
        enabled: pros.settings.authMethodIsNativeSecurity ||
            (enabled && services.password.lockout.timePast()),
        label: widget.buttonLabel == 'Submit'
            ? 'Unlock'
            : (data['buttonLable'] as String? ?? widget.buttonLabel),
        onPressed: () async => submit(),
      );

  Future<void> submit() async {
    setState(() => enabled = false);
    final LocalAuthApi localAuthApi = LocalAuthApi();
    streams.app.authenticating.add(true);
    final bool validate = await localAuthApi.authenticate(
        skip: devFlags.contains(DevFlag.skipPin));
    streams.app.authenticating.add(false);
    if (await services.password.lockout.handleVerificationAttempt(validate)) {
      if (widget.asLoginTime) {
        services.cipher.loginTime();
      }
      streams.app.verify.add(true);
      widget.parentState?.setState(() {});
      (data['onSuccess'] ?? () {})();
    } else {
      if (localAuthApi.reason == AuthenticationResult.error) {
        setState(() {
          enabled = true;
        });
        streams.app.snack.add(Snack(
          message: 'Unknown login error: please set a pin on the device.',
        ));
      } else if (localAuthApi.reason == AuthenticationResult.failure) {
        setState(() {
          failedAttempt = true;
          enabled = true;
        });
      }
    }
  }
}
