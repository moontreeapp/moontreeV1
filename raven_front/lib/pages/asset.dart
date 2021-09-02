import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/text.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/theme/extensions.dart';

class Asset extends StatefulWidget {
  final dynamic data;
  const Asset({this.data}) : super();

  @override
  _AssetState createState() => _AssetState();
}

class _AssetState extends State<Asset> {
  dynamic data = {};
  bool showUSD = false;

  void _toggleUSD() {
    setState(() {
      showUSD = !showUSD;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: header(),
            body: transactionsMetadataView(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: sendReceiveButtons(),
            bottomNavigationBar: RavenButton.bottomNav(context)));
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          elevation: 2,
          centerTitle: false,
          leading: RavenButton.back(context),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: RavenButton.settings(context))
          ],
          title: Text(data['holding']!.security.symbol),
          flexibleSpace: Container(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 15.0),
                    RavenIcon.assetAvatar(data['holding']!.security.symbol),
                    SizedBox(height: 15.0),
                    Text(data['holding']!.value.toString(),
                        style: Theme.of(context).textTheme.headline3),
                    SizedBox(height: 15.0),
                    Text('\$654.02',
                        style: Theme.of(context).textTheme.headline5),
                  ])),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(
                  tabs: [Tab(text: 'Transactions'), Tab(text: 'Metadata')]))));

  /// get metadata from chain or something, store it... need a new reservoir...
  /// interpret it correctly if it is in a recognizable format,
  /// else present file download option
  ListView? _metadataView() {
    return ListView(
        children: [Image(image: AssetImage('assets/magicmusk.png'))]);
    //return null;
  }

  /// filter down to just the transactions for this asset
  ListView _transactionsView() => ListView(children: <Widget>[
        for (var transaction in Current.transactions.where((tx) =>
            tx.security.symbol == data['holding']!.security.symbol)) ...[
          ListTile(
              onTap: () => Navigator.pushNamed(context, '/transaction',
                  arguments: {'transaction': transaction}),
              onLongPress: () => _toggleUSD(),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(transaction.security.symbol,
                        style: Theme.of(context).textTheme.bodyText2),
                    (transaction.value > 0 // == 'in'
                        ? RavenIcon.income(context)
                        : RavenIcon.out(context)),
                  ]),
              trailing: (transaction.value > 0 // == 'in'
                  ? Text(
                      RavenText.securityAsReadable(transaction.value,
                          security: transaction.security, asUSD: showUSD),
                      style: TextStyle(color: Theme.of(context).good))
                  : Text(
                      RavenText.securityAsReadable(transaction.value,
                          security: transaction.security, asUSD: showUSD),
                      style: TextStyle(color: Theme.of(context).bad))),
              leading: RavenIcon.assetAvatar(transaction.security.symbol))
        ]
      ]);

  Container _emptyMessage({IconData? icon, String? name}) => Container(
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon ?? Icons.description,
            size: 50.0, color: Theme.of(context).secondaryHeaderColor),
        Text("\n${data['holding']!.security.symbol} $name empty.\n",
            style: Theme.of(context).textTheme.headline4),
      ]));

  /// returns a list of holdings and transactions or empty messages
  TabBarView transactionsMetadataView() => TabBarView(children: [
        Current.transactions.isEmpty
            ? _emptyMessage(icon: Icons.public, name: 'transactions')
            : _transactionsView(),
        _metadataView() ??
            _emptyMessage(icon: Icons.description, name: 'metadata'),
      ]);

  /// different from home.sendReceiveButtons because it prefills the chosen token
  /// receive works the same
  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        RavenButton.receive(context),
        Current.holdings.length > 0
            ? RavenButton.send(context,
                symbol: data['holding']!.security.symbol)
            : RavenButton.send(context,
                symbol: data['holding']!.security.symbol, disabled: true),
      ]);
}
