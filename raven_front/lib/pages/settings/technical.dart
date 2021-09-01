/// clicking the Accounts name should take you to the accounts technical view
/// where you can move, rename, reorder (must be saved in new reservoir or on
/// accounts objects), delete, move wallets and view details.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';

//import 'package:flutter_treeview/flutter_treeview.dart';
/// make our own 2-layer hierarchy view
/// use draggable to move things between the levels:
///
/// view Balances? should be easy balances are saved by wallet and by account...
///
/// header [ import -> import page, export all accounts -> file]
/// spacer (drag target) [ reorder accounts by dragging ]
/// account [ renamable by click ] (drag target) [ delete, import-> set that account as current and go to import page, export -> file ]
///   wallet [ type and id... ] (draggable) [ delete, view details?, export -> show private key or seed phrase ]
///
/// account order will be saved in settings:
/// settings.accountOrder List
/// settings.saveAccountOrder(List<String> accountIds)

class TechnicalView extends StatefulWidget {
  final dynamic data;
  const TechnicalView({this.data}) : super();

  @override
  _TechnicalViewState createState() => _TechnicalViewState();
}

class _TechnicalViewState extends State<TechnicalView> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
    settings.changes.listen((changes) {
      setState(() {});
    });
    wallets.changes.listen((changes) {
      setState(() {});
    });
    accounts.changes.listen((changes) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
        leading: RavenButton.back(context),
        elevation: 2,
        centerTitle: false,
        title: Text('Technical View'),
      );

  Column body() {
    return Column(children: <Widget>[
      _heading(),
      _accounts(),
    ]);
  }

  ListTile _heading() => ListTile(
        onTap: () {},
        onLongPress: () {},
        leading: RavenIcon.appAvatar(),
        title:
            Text('All Accounts', style: Theme.of(context).textTheme.headline1),
        //trailing: [ import -> import page, export all accounts -> file],
      );

  ListView _accounts() => ListView(children: <Widget>[
        for (var account in accounts.data) ...[
          DragTarget<Account>(
              builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
              ) =>
                  ListTile(
                    onTap: () {},
                    onLongPress: () {/* rename? */},
                    leading: RavenIcon.accountAvatar(),
                    title: Text('---'),
                  ),
              onAcceptWithDetails: (details) {
                var order = settings.accountOrder;
                var movedAccount = details.data;
                order.remove(movedAccount.id);
                order = [
                  for (var item in order) ...[
                    if (item == account.id) ...[movedAccount.id, item] else item
                  ]
                ];
                settings.saveAccountOrder(order);
              }),
          DragTarget<Wallet>(
              builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
              ) =>
                  Draggable<Account>(
                      data: account,
                      child: ListTile(
                        onTap: () {},
                        onLongPress: () {/* rename? */},
                        leading: RavenIcon
                            .accountAvatar(), //alternative Icon(Icons.more_horiz) to show movable
                        title: Text(account.name,
                            style: Theme.of(context).textTheme.headline2),
                        //trailing:  (drag target) [ delete, import-> set that account as current and go to import page, export -> file ],
                      ),
                      feedback: ListTile(
                        onTap: () {},
                        onLongPress: () {/* rename? */},
                        leading: RavenIcon
                            .accountAvatar(), //alternative Icon(Icons.more_horiz) to show movable
                        title: Text(account.name,
                            style: Theme.of(context).textTheme.headline2),
                        //trailing:  (drag target) [ delete, import-> set that account as current and go to import page, export -> file ],
                      )),
              onAcceptWithDetails: (details) {
                /// change the accountId for this wallet and save
                var wallet = details.data;
                wallets.save(wallet is LeaderWallet
                        ? LeaderWallet(
                            id: wallet.id,
                            accountId: account.id,
                            encryptedSeed: wallet.encryptedSeed)
                        : wallet is SingleWallet
                            ? SingleWallet(
                                id: wallet.id,
                                accountId: account.id,
                                encryptedPrivateKey: wallet.encryptedPrivateKey)
                            : SingleWallet(
                                id: wallet.id,
                                accountId: account.id,
                                encryptedPrivateKey: (wallet as SingleWallet)
                                    .encryptedPrivateKey) // placeholder for other wallets
                    );
              }),
          _wallets(account),
        ]
      ]);

  ListView _wallets(account) => ListView(children: <Widget>[
        for (var wallet in wallets.byAccount.getAll(account.id)) ...[
          /// for moving a wallet to a different account...
          Draggable<Wallet>(
              data: wallet,
              child: ListTile(
                onTap: () {/*view details?*/},
                onLongPress: () {},
                leading: RavenIcon.walletAvatar(
                    wallet), //alternative Icon(Icons.more_horiz) to show movable
                title: Text(
                    wallet.kind + ' ' + wallet.id.substring(0, 5) + '...',
                    style: Theme.of(context).textTheme.headline3),
                //trailing: [ delete, view details?, export -> show private key or seed phrase ],
              ),
              feedback: ListTile(
                onTap: () {/*view details?*/},
                onLongPress: () {},
                leading: RavenIcon.walletAvatar(
                    wallet), //alternative Icon(Icons.more_horiz) to show movable
                title: Text(
                    wallet.kind + ' ' + wallet.id.substring(0, 5) + '...',
                    style: Theme.of(context).textTheme.headline3),
                //trailing: [ delete, view details?, export -> show private key or seed phrase ],
              )
              // without childwhiledragging ... if we place it in an illegal location what happens?
              )
        ]
      ]);
}
