import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';

class PeristentKeyboardWatcher extends StatefulWidget {
  const PeristentKeyboardWatcher({Key? key}) : super(key: key);

  @override
  _KeyboardStateHidesWidget createState() => _KeyboardStateHidesWidget();
}

class _KeyboardStateHidesWidget extends State<PeristentKeyboardWatcher> {
  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
        builder: (BuildContext context, bool isKeyboardVisible) {
      if (isKeyboardVisible) {
        streams.app.keyboard.add(KeyboardStatus.up);
      } else {
        streams.app.keyboard.add(KeyboardStatus.down);
      }
      return Container();
    });
  }
}