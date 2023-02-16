import 'dart:io';
import 'package:flutter/services.dart';
import 'package:client_front/presentation/services/services.dart' as services;
import 'package:client_front/presentation/components/components.dart'
    as components;

class SystemBackButton {
  final MethodChannel backButtonChannel = MethodChannel('backButtonChannel');
  final MethodChannel sendToBackChannel = MethodChannel('sendToBackChannel');
  SystemBackButton() {
    listener();
  }

  /// our override to activate our custom back functionality
  Future<void> backButtonPressed() async {
    /// edgecase: if at home screen, minimize app
    if (Platform.isAndroid &&
        components.cubits.title.state.title == 'Holdings') {
      sendToBackChannel.invokeMethod('sendToBackground');
    } else if (services.screenflags.active) {
      /// deactivate the back button in these edge cases...
      // if loading sheet is up do nothing
      // if system dialogue box is up navigator pop
      // if full bottom sheet is up navigator pop
      // if custom bottom modalsheet always in front is up navigator pop
      // instead of pop we should do nothing. the context isn't available and
      // some of these we want to do nothing anyway.
      // Navigator.of(context).pop();
    } else {
      await services.sailor.gobackTrigger();
    }
  }

  void listener() {
    backButtonChannel.setMethodCallHandler((call) async {
      if (call.method == "backButtonPressed") {
        return backButtonPressed();
      }
    });
  }
}
