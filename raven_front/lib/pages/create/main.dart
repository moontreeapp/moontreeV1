// this could be a stateless widget.

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/widgets/widgets.dart';

class CreateMainAsset extends StatefulWidget {
  @override
  _CreateMainAssetState createState() => _CreateMainAssetState();
}

class _CreateMainAssetState extends State<CreateMainAsset> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: body(),
      );

  Widget body() =>
      CreateAsset(preset: FormPresets.main, parent: streams.app.asset.value);
}