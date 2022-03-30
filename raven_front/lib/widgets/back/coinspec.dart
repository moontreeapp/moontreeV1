import 'dart:async';
import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/spend.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';

class CoinSpec extends StatefulWidget {
  final String pageTitle;
  final Security security;

  CoinSpec({
    Key? key,
    required this.pageTitle,
    required this.security,
  }) : super(key: key);

  @override
  _CoinSpecState createState() => _CoinSpecState();
}

class _CoinSpecState extends State<CoinSpec> with TickerProviderStateMixin {
  List<StreamSubscription> listeners = [];
  String symbolSend = 'RVN';
  String symbolTransactions = 'RVN';
  String symbolManage = 'RVN';
  double amount = 0.0;
  double holding = 0.0;
  String visibleAmount = '0';
  String visibleFiatAmount = '';
  String validatedAddress = 'unknown';
  String validatedAmount = '-1';
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(changeContent);
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    tabController.removeListener(changeContent);
    tabController.dispose();
    super.dispose();
  }

  void changeContent() =>
      streams.app.coinspec.add(tabIndex[tabController.index]);

  String get symbol => widget.security.symbol;
  Map<int, String> get tabIndex => {0: 'HISTORY', 1: 'DATA'};

  @override
  Widget build(BuildContext context) {
    var possibleHoldings = [
      for (var balance in Current.holdings)
        if (balance.security.symbol == symbol)
          utils.satToAmount(balance.confirmed)
    ];
    if (possibleHoldings.length > 0) {
      holding = possibleHoldings[0];
    }
    var holdingSat = utils.amountToSat(holding);
    var amountSat = utils.amountToSat(amount);
    try {
      visibleFiatAmount = components.text.securityAsReadable(
          utils.amountToSat(double.parse(visibleAmount)),
          symbol: symbol,
          asUSD: true);
    } catch (e) {
      visibleFiatAmount = '';
    }
    var assetDetails;
    var totalSupply;
    if (widget.pageTitle == 'Asset') {
      assetDetails = widget.pageTitle == 'Asset'
          ? res.assets.bySymbol.getOne(symbol)
          : null;
      if (assetDetails != null) {
        totalSupply =
            utils.satToAmount(assetDetails!.satsInCirculation).toCommaString();
      }
    }
    return Container(
      padding: EdgeInsets.only(top: 16),
      height: 201,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Coin(
              pageTitle: widget.pageTitle,
              symbol: symbol,
              holdingSat: holdingSat,
              totalSupply: totalSupply),
          headerBottom(holdingSat, amountSat),
        ],
      ),
    );
  }

  Widget headerBottom(int holdingSat, int amountSat) {
    if (widget.pageTitle == 'Asset') {
      return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 1),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            symbol.contains('/')
                ? Text('$symbol/',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: AppColors.offWhite))
                : Container(),
          ]));
      //: SizedBox(height: 14+16),
    }
    if (widget.pageTitle == 'Send') {
      return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 1),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Remaining:',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: AppColors.offWhite)),
            Text(
                components.text.securityAsReadable(holdingSat - amountSat,
                    symbol: symbol, asUSD: false),
                //(holding - amount).toString(),
                style: (holding - amount) >= 0
                    ? Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: AppColors.offWhite)
                    : Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: AppColors.error))
          ]));
      //: SizedBox(height: 14+16),
    }
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: _TabIndicator(),
            labelStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                fontWeight: FontWeights.medium,
                letterSpacing: 1.25,
                color: AppColors.white),
            unselectedLabelStyle: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(
                    fontWeight: FontWeights.medium,
                    letterSpacing: 1.25,
                    color: AppColors.white60),
            tabs: [Tab(text: tabIndex[0]), Tab(text: tabIndex[1])]));
  }
}

class _TabIndicator extends BoxDecoration {
  final BoxPainter _painter;

  _TabIndicator() : _painter = _TabIndicatorPainter();

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _TabIndicatorPainter extends BoxPainter {
  final Paint _paint;

  _TabIndicatorPainter()
      : _paint = Paint()
          ..color = Colors.white
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    //final double _xPos = offset.dx + cfg.size!.width / 2;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(
          offset.dx,
          offset.dy + cfg.size!.height + 10,
          offset.dx + cfg.size!.width,
          offset.dy + cfg.size!.height - 2,
        ),
        topLeft: const Radius.circular(8.0),
        topRight: const Radius.circular(8.0),
      ),
      _paint,
    );
  }
}
