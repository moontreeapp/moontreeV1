import 'dart:async';
import 'dart:io' show Platform;
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/services/auth.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin_front/services/wallet.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;

class BackdropAppBarContents extends StatelessWidget
    implements PreferredSizeWidget {
  final bool spoof;
  final bool animate;

  const BackdropAppBarContents(
      {Key? key, this.spoof = false, this.animate = true})
      : super(key: key);

  @override
  Size get preferredSize => const Size(double.infinity, 56);

  @override
  Widget build(BuildContext context) {
    final appBar = Platform.isIOS
        ? buildAppBar(
            context,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark, // For iOS
            ),
            backgroundColor: Colors.transparent,
            shape: components.shape.topRounded8,
          )
        : buildAppBar(
            context,
            backgroundColor: AppColors.primary,
            shape: components.shape.topRounded8,
          );
    /*final alphaBar = Platform.isIOS
        ? Container(
            height: 56,
            child: ClipRect(
              child: Container(
                alignment: Alignment.topRight,
                child: Banner(
                  message: 'alpha',
                  location: BannerLocation.topEnd,
                  color: AppColors.success,
                ),
              ),
            ))
        : ClipRect(
            child: Container(
              alignment: Alignment.topRight,
              child: Banner(
                message: 'alpha',
                location: BannerLocation.topEnd,
                color: AppColors.success,
              ),
            ),
          );*/
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (Platform.isIOS)
          FrontCurve(
            height: 56,
            color: Theme.of(context).backgroundColor,
            fuzzyTop: false,
            frontLayerBoxShadow: const [],
          ),
        testAppBar(appBar, test: true),
        // alphaBar,
        AppBarScrim(),
      ],
    );
  }

  Widget testAppBar(Widget appBar, {bool test = false}) => test
      ? GestureDetector(
          onTap: () async {
            //      height:
            //      0
            //      scripthash:
            //      "e5886c1ed52b9b59a10cb17e7430f26d293b213777b0dc30f999bee9a9cde566"
            //      symbol:
            //      null
            //      txHash:
            //      "c191c775b10d2af1fcccb4121095b2a018f1bee84fa5efb568fcddd383969262"
            //      txPos:
            //      664
            //      value:
            //      64678656394845
            //      hashCode:
            //      977627678

            print(pros.transactions.records);
            await Navigator.pushNamed(
              components.navigator.routeContext!,
              '/security/security',
              arguments: {
                'buttonLabel': 'Submit',
                'onSuccess': () async {
                  Navigator.pop(components.navigator.routeContext!);
                  print('verified');
                }
              },
            );
            //print(pros.unspents.records);
            //print(pros.addresses.byScripthash.getOne(
            //    'e5886c1ed52b9b59a10cb17e7430f26d293b213777b0dc30f999bee9a9cde566'));
            ////EXKwffgqoVuYAq42bGZ5SfMN4KMPmLQhUp
            //print(pros.transactions.primaryIndex.getOne(
            //    'c191c775b10d2af1fcccb4121095b2a018f1bee84fa5efb568fcddd383969262'));
            //print(pros.vouts.records.first);

            //print(streams.claim.unclaimed.value);
            //pros.unspents.records.map((e) => e.symbol).forEach((element) {
            //  print(element);
            //});
            //pros.balances.records.forEach((element) {
            //  print(element);
            //});
            //print(pros.unspents.getSymbolsByWallet(Current.walletId));

            //print(pros.blocks.records.first);
            //print(pros.blocks.records.last);
            //print(pros.settings.chain);
            //print(pros.settings.net);
            //print(pros.settings.domainPort);
            //print(portOf(pros.settings.chain, pros.settings.net));
            //print(pros.settings.mainnet);

            //final txid = 'rU6K7V3Po4snVhBBaU29sesqs2qTQJWDw1';
            //streams.app.snack.add(Snack(
            //  showOnLogin: true,
            //  message: 'Locked', //: ${txid.cutOutMiddle(length: 3)}
            //  label: txid.cutOutMiddle(length: 3),
            //  copy: txid, //: ${txid.cutOutMiddle(length: 3)}
            //  //link: 'https://rvn${pros.settings.mainnet ? '' : 't'}.cryptoscope.io/tx/?txid=$txid'
            //));
            //print(pros.settings.primaryIndex.getAll(SettingName.auth_method));
            //await pros.settings
            //    .setBlockchain(chain: Chain.ravencoin, net: Net.main);
            //await pros.settings.save(
            //    Setting(name: SettingName.blockchain, value: Chain.ravencoin),
            //    force: true);
            //await updateEnumLowerCase();
            //print('rates');
            //var rates = Hive.box<Rate>('rates');
            //for (var x in rates.keys) {
            //  print(x);
            //  print(rates.get(x));
            //}
            //print(pros.securities.USD);
            //updateChain();

            //var box = Hive.box<Setting>('settings');
            //for (var x in box.keys) {
            //  print(x);
            //}

            //print(pros.balances.byWallet.getAll(Current.walletId));
            //for (var x in pros.unspents.records) {
            //  print(x);
            //}
            //print('---');

            //await pros.settings.save(
            //    Setting(name: SettingName.blockchain, value: Chain.evrmore));

            //printFullState();
            //print(pros.settings.advancedDeveloperMode);
            //print(pros.settings.primaryIndex
            //        .getOne(SettingName.mode_dev)
            //        ?.value ==
            //    FeatureLevel.expert);
            //print(
            //    pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value);
            /*
            print(await SecureStorage.authenticationKey);
            var s = Stopwatch()..start();
            var addrs = Current.wallet.addresses;

            /// get histories
            var txs =
                (await services.download.history.getHistories(addrs)).toSet();
            print(txs);
            print('hists: ${s.elapsed}');

            /// get all transaction data about a certain symbol including dangling vins
            //var txs = [
            //  for (var addr in addrs)
            //    await services.download.history.getHistory(addr)
            //].expand((e) => e).toSet();
            //print(txs);
            //print('hist: ${s.elapsed}'); //3 seconds
            //print(txs1.length == txs.length);

            var transactions =
                await services.download.history.grabTransactions(txs);
            print(transactions);
            print('tx: ${s.elapsed}');

            var tuple3s = [
              for (var tx in transactions)
                await services.download.history.parseTx(tx)
            ];
            print(tuple3s); //Tuple3(newTxs, newVins, newVouts);
            print('parse: ${s.elapsed}');

            var relevantTuple3s = <Tuple3>{};
            for (var t3 in tuple3s) {
              for (var vout in t3.item3) {
                if (vout.securityId.split(':').first == 'SATORI') {
                  relevantTuple3s.add(t3);
                }
              }
            }

            print(relevantTuple3s);
            print('filter: ${s.elapsed}');
            */
            //print(pros.vins.danglingOf());
            //print(await pros.balances.delete());
            //print(pros.balances.records);
            //print(Current.wallet.balances.toSet());
            //await services.client.subscribe.toAllAddresses();

            //print(await ((pros.wallets.records.first as LeaderWallet)
            //    .getEntropy)!(pros.wallets.records.first.id));
          },
          child: appBar,
        )
      : appBar;

  Widget buildAppBar(
    BuildContext context, {
    SystemUiOverlayStyle? systemOverlayStyle,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) =>
      AppBar(
        systemOverlayStyle: systemOverlayStyle,
        backgroundColor: backgroundColor,
        shape: shape,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading:
            ['ChooseMethod', 'Login', 'Setup'].contains(streams.app.page.value)
                ? null
                : PageLead(mainContext: context),
        centerTitle: spoof,
        title: PageTitle(animate: animate),
        actions: <Widget>[
          /// thought it might be nice to have an indicator of which blockchain
          /// is being used, but I think we can make better use of the real
          /// estate by moving the options to the network page, and moving the
          /// validation to during the "connect" process rather than before the
          /// page is shown, so commenting out here for now. instead of the
          /// status light we could show the icon of the current blockchain with
          /// an overlay color of the status. then if the option was on the
          /// network page that would make sense.
          //if (!spoof) ChosenBlockchain(),
          /// this is not needed since we have a shimmer and we'll subtle color
          /// the connection light in the event that we have network activity.
          //if (!spoof) ActivityLight(),
          if (!spoof) spoof ? SpoofedConnectionLight() : ConnectionLight(),
          if (!spoof) QRCodeContainer(),
          if (!spoof) SnackBarViewer(),
          if (!spoof) SizedBox(width: 6),
          if (!spoof) components.status,
          if (!spoof) PeristentKeyboardWatcher(),
        ],
      );
}
