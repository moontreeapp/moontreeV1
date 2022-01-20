import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var existingPassword = TextEditingController();
  var newPassword = TextEditingController();
  FocusNode newPasswordFocusNode = FocusNode();
  String existingNotification = '';
  String newNotification = '';
  bool existingPasswordVisible = false;
  bool newPasswordVisible = false;
  bool validatedExisting = false;
  bool? validatedComplexity;

  @override
  void initState() {
    existingPasswordVisible = false;
    newPasswordVisible = false;
    validatedExisting = false;
    super.initState();
  }

  @override
  void dispose() {
    existingPassword.dispose();
    newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: body(),
      );

  ElevatedButton submitButton(context) => ElevatedButton.icon(
      onPressed: validateExistingCondition(validatedExisting) &&
              validateComplexityCondition(validatedComplexity)
          ? () async => await submit()
          : () {},
      icon: Icon(Icons.login),
      label: Text('Submit'),
      style: validateExistingCondition(validatedExisting) &&
              validateComplexityCondition(validatedComplexity)
          ? null
          : ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).disabledColor))
      //style: validateExistingCondition(validatedExisting) &&
      //        validateComplexityCondition(validatedComplexity)
      //    ? components.styles.buttons.curvedSides
      //    : components.styles.buttons.disabledCurvedSides(context)
      );

  bool validateExistingCondition([validatedExisting]) =>
      services.password.required
          ? validatedExisting ?? validateExisting()
          : true;

  bool validateComplexityCondition([givenValidatedComplexity]) =>
      givenValidatedComplexity ?? false ?? validateComplexity();

  Widget body() {
    var newPasswordField = TextField(
      focusNode: newPasswordFocusNode,
      autocorrect: false,
      controller: newPassword,
      obscureText: !newPasswordVisible,
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'new password',
        hintText: 'new password',
        helperText: [null, false].contains(validatedComplexity)
            ? null
            : newNotification,
        errorText: [null, false].contains(validatedComplexity)
            ? newNotification
            : null,
        suffixIcon: IconButton(
          icon: Icon(
              newPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0x99000000)),
          onPressed: () => setState(() {
            newPasswordVisible = !newPasswordVisible;
          }),
        ),
      ),
      onChanged: (String value) => validateComplexity(password: value),
      onEditingComplete: () async => await submit(),
    );
    var existingPasswordField = TextField(
      autocorrect: false,
      enabled: services.password.required ? true : false,
      controller: existingPassword,
      obscureText: !existingPasswordVisible,
      textInputAction: TextInputAction.next,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'existing password',
        hintText: 'existing password',
        helperText: validatedExisting ? existingNotification : null,
        errorText: validatedExisting ? null : existingNotification,
        suffixIcon: IconButton(
          icon: Icon(
              existingPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0x99000000)),
          onPressed: () => setState(() {
            existingPasswordVisible = !existingPasswordVisible;
          }),
        ),
      ),
      onChanged: (String value) {
        if (validateExisting()) {
          FocusScope.of(context).requestFocus(newPasswordFocusNode);
        }
      },
      onEditingComplete: () => validateExisting(),
    );
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  services.password.required
                      ? existingPasswordField
                      : newPasswordField,
                ]),
            Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: 40,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [submitButton(context)]))
          ],
        ));
  }

  bool validateExisting({String? password}) {
    password = password ?? existingPassword.text;
    if (services.password.validate.password(password)) {
      existingNotification = 'success!';
      validatedExisting = true;
      setState(() => {});
      return true;
    }
    var old = validatedExisting;
    var oldNotification = existingNotification;
    var used = services.password.validate.previouslyUsed(password);
    existingNotification = used == null
        ? 'password unrecognized...'
        : 'this password was used $used passwords ago';
    validatedExisting = false;
    if (old || oldNotification != existingNotification) setState(() => {});
    return false;
  }

  bool validateComplexity({String? password}) {
    password = password ?? newPassword.text;
    var used;
    var oldNotification = newNotification;
    if (services.password.validate.complexity(password)) {
      used = services.password.validate.previouslyUsed(password);
      newNotification = used == null
          ? 'This password has never been used and is a strong password'
          : used > 0
              ? 'Warnning: this password was used $used passwords ago'
              : 'This is your current password';
      if (used != 0) {
        validatedComplexity = true;
        setState(() => {});
        return true;
      }
    }
    var old = validatedComplexity;
    if (used != 0) {
      newNotification = ('weak password: '
          '${services.password.validate.complexityExplained(password).join(' & ')}.');
    }
    validatedComplexity = false;
    if (old != validatedComplexity || oldNotification != newNotification)
      setState(() => {});
    return false;
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future submit() async {
    if (validateComplexity() && validateExistingCondition()) {
      FocusScope.of(context).unfocus();
      var password = newPassword.text;
      await services.password.create.save(password);

      // todo: replace with responsive 'ecrypting wallet x, y, z... etc'
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
              title: Text('Re-encrypting Wallets...'),
              content: Text('Estimated wait time: ' +
                  _printDuration(Duration(seconds: wallets.data.length * 2)) +
                  ', please wait...')));
      // this is used to get the please wait message to show up
      // it needs enough time to display the message
      await Future.delayed(const Duration(milliseconds: 150));

      var cipher = services.cipher.updatePassword(altPassword: password);
      await services.cipher.updateWallets(cipher: cipher);
      services.cipher.cleanupCiphers();
      Navigator.of(context).pop(); // for please wait
      successMessage();
    }
  }

  Future successMessage() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: Text('Success!'),
              content: Text('Please back up your password!\n\n'
                  'There is NO recovery process for lost passwords!'),
              actions: [
                TextButton(
                    child: Text('ok'),
                    onPressed: () {
                      validateComplexity();
                      Navigator.of(context).pop();
                    })
              ]));
}
