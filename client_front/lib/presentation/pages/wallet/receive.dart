import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/domain/utils/params.dart';
import 'package:client_front/domain/utils/transformers.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:share/share.dart';

class Receive extends StatefulWidget {
  final dynamic data;
  const Receive({this.data}) : super();

  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  Map<String, dynamic> data = <String, dynamic>{};
  String? address;
  final TextEditingController requestMessage = TextEditingController();
  final TextEditingController requestAmount = TextEditingController();
  final TextEditingController requestLabel = TextEditingController();
  FocusNode requestAmountFocus = FocusNode();
  FocusNode requestLabelFocus = FocusNode();
  FocusNode requestMessageFocus = FocusNode();
  FocusNode shareFocus = FocusNode();
  String uri = '';
  String username = '';
  String? errorText;
  List<Security> fetchedNames = <Security>[];
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];

  bool get rawAddress =>
      requestMessage.text == '' &&
      requestAmount.text == '' &&
      requestLabel.text == '';

  void _makeURI({bool refresh = true}) {
    if (rawAddress) {
      uri = address!;
    } else {
      final String amount = requestAmount.text == ''
          ? ''
          : 'amount=${Uri.encodeComponent(requestAmount.text)}';
      final String label = requestLabel.text == ''
          ? ''
          : 'label=${Uri.encodeComponent(requestLabel.text)}';
      final String message = requestMessage.text == ''
          ? ''
          //: 'message=${Uri.encodeComponent(requestMessage.text)}';
          : 'message=asset:${Uri.encodeComponent(requestMessage.text)}';
      final String to =
          username == '' ? '' : 'to=${Uri.encodeComponent(username)}';

      /// should we add the rest of the fields?
      //var net = x == '' ? '' : 'net=${Uri.encodeComponent(x)}';
      //var fee = x == '' ? '' : 'fee=${Uri.encodeComponent(x)}';
      //var note = x == '' ? '' : 'note=${Uri.encodeComponent(x)}';
      //var memo = x == '' ? '' : 'memo=${Uri.encodeComponent(x)}';

      String tail =
          <String>[amount, label, message, to].join('&').replaceAll('&&', '&');
      tail =
          '?${tail.endsWith('&') ? tail.substring(0, tail.length - 1) : tail}';
      tail = tail.length == 1 ? '' : tail;
      uri = '${pros.settings.chain.name.replaceAll('coin', '')}:$address$tail';
    }
    if (refresh) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    //var s = Stopwatch()..start();
    requestMessage.addListener(_printLatestValue);
    //print('init: ${s.elapsed}');
    /// when the client isn't busy anymore, refresh
    listeners.add(streams.client.busy.listen((bool busy) async {
      if (!busy && Current.wallet.addressesFor().isNotEmpty) {
        print('receive triggered by client not busy');
        address = null;
        setState(() {});
      }
    }));

    listeners.add(pros.addresses.change.listen((Change<Address> change) async {
      change.when(
          loaded: (_) {},
          added: (_) {
            if (Current.wallet.externalAddresses.length == 1 ||
                Current.wallet.addressesFor().length > 39) {
              print('receive triggered by new address');
              address = null;
              setState(() {});
            }
          },
          updated: (_) {},
          removed: (_) {});
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    // Clean up the controller when the widget is disposed.
    requestMessage.dispose();
    requestAmount.dispose();
    requestLabel.dispose();
    shareFocus.dispose();
    super.dispose();
  }

  Future<void> _printLatestValue() async {
    fetchedNames = requestMessage.text.length <= 32
        ? (await services.client.api.getAssetNames(requestMessage.text))
            .toList()
            .map((String e) => Security(
                  symbol: e,
                  chain: pros.settings.chain,
                  net: pros.settings.net,
                ))
            .toList()
        : <Security>[];
  }

  @override
  Widget build(BuildContext context) {
    username = pros.settings.primaryIndex.getOne(SettingName.user_name)?.value
            as String? ??
        '';
    data = populateData(context, data);
    requestMessage.text = requestMessage.text == ''
        ? data.containsKey('symbol') && data['symbol'] as String != ''
            ? data['symbol']! as String
            : ''
        : requestMessage.text;
    address = services.wallet.getEmptyAddress(
      Current.wallet,
      NodeExposure.external,
      address: address,
    );
    uri = uri == '' ? address! : uri;
    //requestMessage.selection =
    //    TextSelection.collapsed(offset: requestMessage.text.length);
    if (requestMessage.text != '') {
      _makeURI(refresh: false);
    }
    final double height = 1.ofAppHeight;
    return FrontCurve(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _makeURI();
          },
          child: body(height),
        ));
  }

  bool get smallScreen => MediaQuery.of(context).size.height < 640;

  Widget body(double height) => Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SingleChildScrollView(
              child: Container(
                  height: height,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 16),
                          child: GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: address));
                                streams.app.snack.add(Snack(
                                    message: 'Address copied to clipboard'));
                                // not formatted the same...
                                //ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                                //  content: new Text("Copied to Clipboard"),
                                //));
                              },
                              onLongPress: () {
                                Clipboard.setData(ClipboardData(
                                    text: rawAddress ? address : uri));
                                streams.app.snack.add(
                                    Snack(message: 'URI copied to clipboard'));
                                // not formatted the same...
                                //ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                                //  content: new Text("Copied to Clipboard"),
                                //));
                              },
                              child: Center(

                                  /// long hold copy and maybe on tap?
                                  child: QrImage(
                                      backgroundColor: Colors.white,
                                      data: rawAddress ? address! : uri,
                                      foregroundColor: AppColors.primary,
                                      //embeddedImage: Image.asset(
                                      //        'assets/logo/moontree_logo.png')
                                      //    .image,
                                      size: smallScreen ? 150 : 300.0)))),
                      /* we can remove these two visibles just by commenting it out if we want: */
                      Visibility(
                        visible: rawAddress,
                        child: SelectableText(
                          address!,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(color: AppColors.black87),
                          showCursor: true,
                          toolbarOptions:
                              const ToolbarOptions(copy: true, selectAll: true),
                        ),
                      ),
                      Visibility(
                        visible: rawAddress,
                        child: const SizedBox(height: 8),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Column(
                            children: <Widget>[
                              /// if this is a RVNt account we could show that here...
                              //SizedBox(height: 15.0),
                              //Text(
                              //    // rvn is default but if balance is 0 then take the largest asset balance and also display name here.
                              //    'RVN',
                              //    textAlign: TextAlign.center),

                              /// At this time we're not going to show them any information but the
                              /// QR Code, not even the address, if they copy by long pressing the
                              /// QR Code, they can get the address or this information if its
                              /// constructed.
                              //SizedBox(height: 10.0),
                              //Center(
                              //    child: Column(
                              //        crossAxisAlignment: CrossAxisAlignment.center,
                              //        children: <Widget>[
                              //      /// does not belong on UI but I still want an indication that what is on QR code is not raw address...
                              //      Visibility(
                              //          visible: !rawAddress,
                              //          child: Text(
                              //            'raven:',
                              //            style: Theme.of(context).textTheme.caption,
                              //          )),
                              //      SelectableText(
                              //        address,
                              //        cursorColor: Colors.grey[850],
                              //        showCursor: true,
                              //        toolbarOptions: ToolbarOptions(
                              //            copy: true, selectAll: true, cut: false, paste: false),
                              //      ),
                              //      Visibility(
                              //          visible: !rawAddress && username != '',
                              //          child: Text(
                              //            'to: $username',
                              //            style: Theme.of(context).textTheme.caption,
                              //          )),
                              //      Visibility(
                              //          visible: !rawAddress && requestMessage.text != '',
                              //          child: Text(
                              //            'asset: ${requestMessage.text}',
                              //            style: Theme.of(context).textTheme.caption,
                              //          )),
                              //      Visibility(
                              //          visible: !rawAddress && requestAmount.text != '',
                              //          child: Text(
                              //            'amount: ${requestAmount.text}',
                              //            style: Theme.of(context).textTheme.caption,
                              //          )),
                              //      Visibility(
                              //          visible: !rawAddress && requestLabel.text != '',
                              //          child: Text(
                              //            'note: ${requestLabel.text}',
                              //            style: Theme.of(context).textTheme.caption,
                              //          )),
                              //    ])),
                              //SizedBox(height: 20.0),

                              /// this autocomplete will actually populate after 3 characters
                              /// have been entered by asking electrum what assets start
                              /// with those 3 characters. However, this is old functionality
                              /// and will have to be modified anyway (because of our special
                              /// use of subsassets namespaces etc), Furthermore, it seems
                              /// an Autocomplete widget doesn't accept an InputDecoration,
                              /// making formatting it to look the same as the others difficult
                              /// thus, we're commenting it out now, in order to extract it's
                              /// functionality later and currently replacing it with a simple
                              /// text field.
                              //Column(
                              //    crossAxisAlignment: CrossAxisAlignment.start,
                              //    mainAxisAlignment: MainAxisAlignment.start,
                              //    children: <Widget>[
                              //      const SizedBox(height: 15),
                              //      Text(
                              //        'Requested Asset:',
                              //        style: TextStyle(color: Theme.of(context).hintColor),
                              //      ),
                              //      Autocomplete<Security>(
                              //        displayStringForOption: _displayStringForOption,
                              //        initialValue: TextEditingValue(text: requestMessage.text),
                              //        optionsBuilder: (TextEditingValue textEditingValue) {
                              //          requestMessage.text = textEditingValue.text;
                              //          _makeURI();
                              //          if (requestMessage.text == '') {
                              //            return const Iterable<Security>.empty();
                              //          }
                              //          if (requestMessage.text == 't') {
                              //            return [
                              //              Security(symbol: 'testing')
                              //            ];
                              //          }
                              //          if (requestMessage.text.length >= 3) {
                              //            return fetchedNames;
                              //          }
                              //          //(await services.client.api.getAllAssetNames(textEditingValue.text)).map((String s) => Security(
                              //          //        symbol: s));
                              //          return securities.data
                              //              .where((Security option) => option.symbol
                              //                  .contains(requestMessage.text.toUpperCase()))
                              //              .toList()
                              //              .reversed;
                              //        },
                              //        optionsMaxHeight: 100,
                              //        onSelected: (Security selection) async {
                              //          requestMessage.text = selection.symbol;
                              //          _makeURI();
                              //          FocusScope.of(context).requestFocus(requestAmountFocus);
                              //        },
                              //      ),
                              //      const SizedBox(height: 15.0),
                              //    ]),
                              TextFieldFormatted(
                                  focusNode: requestMessageFocus,
                                  controller: requestMessage,
                                  autocorrect: false,
                                  textInputAction: TextInputAction.next,
                                  // I don't think this formatter is right so
                                  // I'm commenting it out. why should we limit
                                  // the requests to only main assets? shouldn't
                                  // users be able to request nfts and the like?
                                  //inputFormatters: <MainAssetNameTextFormatter>[
                                  //  MainAssetNameTextFormatter(),
                                  //],
                                  //maxLength: 32,
                                  //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                  labelText: 'Requested Asset',
                                  hintText: 'MOONTREE',
                                  errorText: errorText,
                                  suffixIcon: requestMessage.text == ''
                                      ? null
                                      : IconButton(
                                          alignment: Alignment.centerRight,
                                          //padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.close_rounded,
                                              color: AppColors.black60),
                                          onPressed: () => setState(() {
                                                requestMessage.text = '';
                                                data['symbol'] = null;
                                              })),
                                  onTap: _makeURI,
                                  onChanged: (String value) {
                                    //requestMessage.text =
                                    //    cleanLabel(requestMessage.text);
                                    //_makeURI();
                                    final String? oldErrorText = errorText;
                                    errorText =
                                        value.length > 32 ? 'too long' : null;
                                    if (oldErrorText != errorText) {
                                      setState(() {});
                                    }
                                  },
                                  onEditingComplete: () {
                                    requestMessage.text =
                                        cleanLabel(requestMessage.text);
                                    _makeURI();
                                    FocusScope.of(context)
                                        .requestFocus(requestAmountFocus);
                                  }),
                              const SizedBox(height: 16),
                              TextFieldFormatted(
                                  focusNode: requestAmountFocus,
                                  controller: requestAmount,
                                  autocorrect: false,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  labelText: 'Amount',
                                  hintText: 'Quantity',
                                  onTap: _makeURI,
                                  onChanged: (String value) {
                                    //requestAmount.text = cleanDecAmount(requestAmount.text);
                                    //_makeURI();
                                  },
                                  onEditingComplete: () {
                                    requestAmount.text = cleanDecAmount(
                                      requestAmount.text,
                                      zeroToBlank: true,
                                    );
                                    _makeURI();
                                    FocusScope.of(context)
                                        .requestFocus(requestLabelFocus);
                                  }),
                              const SizedBox(height: 16),
                              TextFieldFormatted(
                                focusNode: requestLabelFocus,
                                autocorrect: false,
                                controller: requestLabel,
                                textInputAction: TextInputAction.done,
                                labelText: 'Note',
                                hintText: 'for groceries',
                                onTap: _makeURI,
                                onChanged: (String value) {
                                  //requestLabel.text = cleanLabel(requestLabel.text);
                                  //_makeURI();
                                },
                                onEditingComplete: () {
                                  requestLabel.text =
                                      cleanLabel(requestLabel.text);
                                  _makeURI();
                                  //FocusScope.of(context).unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(shareFocus);
                                },
                              ),
                            ],
                          )),
                      if (!smallScreen) SizedBox(height: 72.figmaH)
                    ],
                  ))),
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(height: height + 48),
              KeyboardHidesWidgetWithDelay(
                  child: components.containers.navBar(context,
                      child: Row(children: <Widget>[shareButton]))),
            ],
          ),
        ],
      );

  /// see Autocomplete above
  //static String _displayStringForOption(Security option) => option.symbol;

  Widget get shareButton => components.buttons.actionButton(
        context,
        label: 'Share',
        focusNode: shareFocus,
        onPressed: () => Share.share(uri),
      );
}