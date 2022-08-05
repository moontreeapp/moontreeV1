import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class QRCodeContainer extends StatefulWidget {
  QRCodeContainer({Key? key}) : super(key: key);

  @override
  _QRCodeContainerState createState() => _QRCodeContainerState();
}

class _QRCodeContainerState extends State<QRCodeContainer> {
  late String pageTitle = 'Home';
  late List listeners = [];
  final List<String> blanks = [
    'main',
    '',
    'Scan',
    'Send',
    'Login',
    'Splash',
    'Createlogin'
  ];
  late bool loading = false;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.loading.listen((bool value) {
      if (value != loading) {
        setState(() {
          loading = value;
        });
      }
    }));
    listeners.add(streams.app.page.listen((value) {
      if (((blanks.contains(value) && !blanks.contains(pageTitle)) ||
          (!blanks.contains(value) && blanks.contains(pageTitle)))) {
        setState(() {
          pageTitle = value;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => loading
      ? Container(width: 0)
      : {
            'Send': Padding(
                padding: EdgeInsets.only(left: 0),
                child: QRCodeButton(pageTitle: 'Send-to')),
          }[pageTitle] ??
          (blanks.contains(pageTitle)
              ? Container(width: 0)
              : Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: QRCodeButton(pageTitle: pageTitle)));
}