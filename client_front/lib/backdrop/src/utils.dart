import 'package:flutter/material.dart';
import 'package:client_front/backdrop/backdrop.dart';
import 'package:client_back/streams/streams.dart';

void flingBackdrop(BuildContext context) {
  streams.app.setting
      .add(Backdrop.of(context).isBackLayerRevealed ? null : 'open');
  Backdrop.of(context).fling();
}