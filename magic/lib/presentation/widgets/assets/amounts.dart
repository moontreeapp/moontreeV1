import 'package:flutter/material.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/extensions.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/services/services.dart';

class CoinBalanceView extends StatelessWidget {
  final Coin coin;
  final TextStyle? wholeStyle;
  final TextStyle? partOneStyle;
  final TextStyle? partTwoStyle;
  final TextStyle? partThreeStyle;
  const CoinBalanceView({
    super.key,
    required this.coin,
    this.wholeStyle,
    this.partOneStyle,
    this.partTwoStyle,
    this.partThreeStyle,
  });

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.bottomCenter,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(coin.whole(),
                style: wholeStyle ??
                    (coin.coin > 0
                        ? AppText.wholeHolding
                        : AppText.partHolding)),
            if (coin.sats > 0) ...[
              for (final e in coin.boldedPart())
                Text(e.char,
                    style: partOneStyle ??
                        (e.bolded
                            ? AppText.partHoldingBright
                            : AppText.partHolding)),
              //Text(coin.partOne(),
              //    style: partOneStyle ??
              //        AppText.partHolding.copyWith(
              //            //height: 1.625 + .15
              //            )),
              ////const SizedBox(width: 4),
              //Text(coin.partTwo(),
              //    style: partTwoStyle ??
              //        AppText.partHolding.copyWith(
              //            //height: 1.625 + .3,
              //            //fontSize: 12,
              //            //height: 1.625 + .6,
              //            //fontSize: 10,
              //            )),
              //const SizedBox(width: 4),
              //Text(coin.partThree(),
              //    style: partThreeStyle ??
              //        AppText.partHolding.copyWith(
              //            // how do I align at with bottom?
              //            //height: 1.625 + .6,
              //            //fontSize: 10,
              //            ))
            ],
          ]));
}

class CoinBalanceSimpleView extends StatelessWidget {
  final Coin coin;
  final TextStyle? wholeStyle;
  final TextStyle? partStyle;
  const CoinBalanceSimpleView({
    super.key,
    required this.coin,
    this.wholeStyle,
    this.partStyle,
  });

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.bottomCenter,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(coin.whole(),
                style: wholeStyle ??
                    (coin.coin > 0
                        ? AppText.wholeHolding
                        : AppText.partHolding)),
            if (coin.sats > 0) ...[
              Text(coin.part(),
                  style: partStyle ??
                      AppText.partHolding.copyWith(
                          //height: 1.625 + .15
                          )),
            ],
          ]));
}

class CoinBalancePriceSimpleView extends StatefulWidget {
  final Coin coin;
  final String alt;
  final TextStyle? wholeStyle;
  final TextStyle? partStyle;

  const CoinBalancePriceSimpleView({
    super.key,
    required this.coin,
    this.alt = '',
    this.wholeStyle,
    this.partStyle,
  });

  @override
  CoinBalancePriceSimpleViewState createState() =>
      CoinBalancePriceSimpleViewState();
}

class CoinBalancePriceSimpleViewState extends State<CoinBalancePriceSimpleView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showOriginalText = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleText() {
    if (_controller.isAnimating) return;

    _controller.forward().then((_) {
      setState(() {
        _showOriginalText = !_showOriginalText;
      });
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleText,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          width: screen.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _showOriginalText ? widget.coin.whole() : widget.alt,
                style: widget.wholeStyle ??
                    (widget.coin.coin > 0
                        ? AppText.wholeHolding
                        : AppText.partHolding),
              ),
              if (widget.coin.sats > 0 && _showOriginalText) ...[
                Text(
                  widget.coin.part(),
                  style: widget.partStyle ?? AppText.partHolding.copyWith(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CoinView extends StatelessWidget {
  final Coin coin;
  final TextStyle? wholeStyle;
  final TextStyle? partOneStyle;
  final TextStyle? partTwoStyle;
  final TextStyle? partThreeStyle;
  final DifficultyMode? mode;
  final TextAlign textAlign;
  const CoinView({
    super.key,
    required this.coin,
    this.wholeStyle,
    this.partOneStyle,
    this.partTwoStyle,
    this.partThreeStyle,
    this.mode,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) =>
      (mode ?? cubits.menu.state.mode) == DifficultyMode.easy
          ? Text(coin.simplified(),
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(height: 0, color: AppColors.white60))
          : RichText(
              textAlign: textAlign,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              text: TextSpan(
                style: wholeStyle ??
                    Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(height: 0, color: AppColors.white60),
                children: <TextSpan>[
                  TextSpan(text: coin.whole()),
                  if (coin.sats > 0) ...[
                    TextSpan(
                        text: coin.partOne(),
                        style: partOneStyle ??
                            Theme.of(context).textTheme.body1.copyWith(
                                height: 0,
                                fontSize: 14,
                                color: AppColors.black38)),
                    TextSpan(
                        text: coin.partTwo(),
                        style: partTwoStyle ??
                            Theme.of(context).textTheme.body1.copyWith(
                                //height: 1.625 + .3,
                                //fontSize: 12,
                                height: 0,
                                fontSize: 10,
                                color: AppColors.black38)),
                    TextSpan(
                        text: coin.partThree(),
                        style: partThreeStyle ??
                            Theme.of(context).textTheme.body1.copyWith(
                                // how do I align at with bottom?
                                height: 0,
                                fontSize: 10,
                                color: AppColors.black38))
                  ],
                ],
              ),
            );
}

class CoinSplitView extends StatelessWidget {
  final Coin coin;
  final TransactionDisplay display;
  final double space;
  const CoinSplitView({
    super.key,
    required this.coin,
    required this.display,
    this.space = 2,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
      width: screen.width * .375,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RichText(
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                text: TextSpan(
                    style: Theme.of(context).textTheme.body1,
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              '${display.incoming ? '+' : '-'}${coin.whole()}',
                          style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight:
                                    display.incoming ? FontWeight.bold : null,
                                color: display.incoming
                                    ? AppColors.success
                                    : AppColors.white60,
                              )),
                      TextSpan(
                          text: coin.partOne(),
                          style: Theme.of(context).textTheme.body1.copyWith(
                                height: 0,
                                color: display.incoming
                                    ? AppColors.success
                                    : AppColors.white60,
                              )),
                    ])),
            Text(coin.spacedEnding(),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.body1.copyWith(
                      height: 0,
                      fontSize: 10,
                      color: display.incoming
                          ? AppColors.success
                          : AppColors.white60,
                    )),
            SizedBox(height: space),
          ]));
}

class SimpleCoinSplitView extends StatelessWidget {
  final Coin coin;
  final DifficultyMode? mode;
  final bool? incoming;
  const SimpleCoinSplitView({
    super.key,
    required this.coin,
    this.mode,
    this.incoming = false,
  });

  @override
  Widget build(BuildContext context) => (mode ?? cubits.menu.state.mode) ==
          DifficultyMode.easy
      ? Text(coin.simplified(),
          style: Theme.of(context)
              .textTheme
              .body1
              .copyWith(height: 0, color: AppColors.white60))
      : SizedBox(
          //width: screen.width * .375,
          child: RichText(
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              text: TextSpan(
                  style: Theme.of(context).textTheme.body1,
                  children: <TextSpan>[
                    /// I don't think the plus and minus is necessary.
                    if (incoming == true)
                      TextSpan(
                          text: '+',
                          style: Theme.of(context).textTheme.body1.copyWith(
                                height: 0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ))
                    else if (incoming == false)
                      TextSpan(
                          text: '-',
                          style: Theme.of(context).textTheme.body1.copyWith(
                              height: 0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white87 //.withOpacity(.67),
                              )),
                    TextSpan(
                        text: coin.whole(),
                        style: Theme.of(context).textTheme.body1.copyWith(
                              height: 0,
                              fontWeight: coin.coin > 0
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: incoming == true
                                  ? (coin.coin > 0
                                      ? AppColors.success
                                      : AppColors.success67)
                                  : (coin.coin > 0
                                      ? AppColors.white87
                                      : AppColors.white67),
                            )),
                    //TextSpan(
                    //    text: coin.spacedPart(),
                    //    style: Theme.of(context).textTheme.body1.copyWith(
                    //          height: 0,
                    //          color: AppColors.white60,
                    //        )),
                    //...() {
                    //  var bolded = false;
                    //  final ret = [];
                    //  for (final i in coin.part().characters) {
                    //    if (i != '0' && i != '.') bolded = true;
                    //    ret.add(TextSpan(
                    //        text: i,
                    //        style: Theme.of(context).textTheme.body1.copyWith(
                    //              height: 0,
                    //              fontWeight: bolded ? FontWeight.w700 : null,
                    //              color: AppColors.white60,
                    //            )));
                    //  }
                    //  return ret;
                    //}(),
                    ...[
                      for (final e in coin.boldedPart())
                        TextSpan(
                            text: e.char,
                            style: Theme.of(context).textTheme.body1.copyWith(
                                  height: 0,
                                  fontWeight: e.bolded && coin.coin == 0
                                      ? FontWeight.w700
                                      : e.bolded && coin.coin > 0
                                          ? FontWeight.w400
                                          : FontWeight.w400,
                                  color: incoming == true
                                      ? (e.bolded
                                          ? AppColors.success
                                          : AppColors.success67)
                                      : (e.bolded
                                          ? AppColors.white87
                                          : AppColors.white67),
                                ))
                    ],
                  ])),
        );
}

class FiatView extends StatelessWidget {
  final Fiat fiat;
  final TextStyle? wholeStyle;
  final TextStyle? partStyle;
  const FiatView({
    super.key,
    required this.fiat,
    this.wholeStyle,
    this.partStyle,
  });

  @override
  Widget build(BuildContext context) =>
      cubits.menu.state.mode == DifficultyMode.easy
          ? Text(fiat.simplified(),
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: AppColors.white60))
          : (String humanString) {
              return RichText(
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                text: TextSpan(children: [
                  TextSpan(
                    text: humanString.split('.').first,
                    style: wholeStyle ??
                        Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(height: 0, color: AppColors.white60),
                  ),
                  if (humanString != '\$0.00' && humanString != '\$-')
                    TextSpan(
                      text: '.${humanString.split('.').last}',
                      style: wholeStyle ??
                          Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(height: 0, color: AppColors.white60),
                    ),
                ]),
              );
            }(fiat.humanString());
}
