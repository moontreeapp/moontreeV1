import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic/cubits/canvas/holding/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/pool/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/presentation/ui/pane/wallet/page.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';
import 'package:magic/presentation/widgets/animations/hiding.dart';
import 'package:magic/presentation/widgets/assets/amounts.dart';
import 'package:magic/services/services.dart' show maestro, screen;
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';
import 'package:magic/domain/concepts/asset_icons.dart';

Holding getHoldingOf(Blockchain blockchain) => cubits.wallet.state.holdings
    .where((x) => x.blockchain == blockchain && x.isCurrency)
    .first;

class HodingDetailPage extends StatelessWidget {
  const HodingDetailPage({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: screen.width,
      height: screen.height,
      padding: EdgeInsets.only(top: screen.appbar.height),
      alignment: Alignment.topCenter,
      child: Container(
          width: screen.width,
          height: screen.canvas.midHeight,
          alignment: Alignment.center,
          child: const AnimatedCoinSpec()));
}

class AnimatedCoinSpec extends StatelessWidget {
  const AnimatedCoinSpec({super.key});

  Widget assetIcon() {
    final holding = cubits.holding.state.holding;
    final blockchain = holding.blockchain;
    final heightWidth = screen.iconHuge + 12;
    return Container(
      width: screen.width,
      alignment: Alignment.center,
      child: cubits.holding.state.section == HoldingSection.pool
          ? SimpleIdenticon(
              letter: '',
              height: heightWidth,
              width: heightWidth,
              style: AppText.identiconHuge,
              admin: holding.isAdmin,
              blockchain: blockchain,
              showAppIcon: true,
            )
          : holding.asset.name.toLowerCase() == 'satori'
              ? SimpleIdenticon(
                  letter: '',
                  height: heightWidth,
                  width: heightWidth,
                  style: AppText.identiconHuge,
                  admin: holding.isAdmin,
                  blockchain: blockchain,
                  //showBlockchainIcon: true,
                  showPoolIndicatorIcon: true,
                )
              : holding.isCurrency
                  ? CurrencyIdenticon(
                      holding: holding,
                      height: heightWidth,
                      width: heightWidth,
                    )
                  : holding.weHaveAdminOrMain
                      ? () {
                          final pair = cubits.wallet
                              .mainAndAdminOf(cubits.holding.state.holding);
                          return TokenToggle(
                            height: heightWidth,
                            width: heightWidth,
                            style: AppText.identiconHuge,
                            mainHolding: pair.main!,
                            adminHolding: pair.admin!,
                          );
                        }()
                      : AssetIcons.hasCustomIcon(holding.name, blockchain)
                          ? AssetIdenticon(
                              holding: holding,
                              height: heightWidth,
                              width: heightWidth,
                              blockchain: blockchain,
                            )
                          : SimpleIdenticon(
                              letter: cubits
                                  .holding.state.holding.assetPathChildNFT[0],
                              height: heightWidth,
                              width: heightWidth,
                              style: AppText.identiconHuge,
                              admin: holding.isAdmin,
                              blockchain: blockchain,
                            ),
    );
  }

  Widget assetValues({
    String? whole,
    String? part,
    String? subtitle,
    Coin? coin,
  }) {
    final dollarText = cubits.holding.state.usd;
    final showSubtitle =
        subtitle != null; //!['\$ -', '\$ 0.00'].contains(dollarText);
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      //if (!showDollar)
      const SizedBox(height: 24),
      //else
      //  const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (whole == null)
          if ((coin?.coin ?? cubits.holding.state.holding.coin.coin) > 0)
            CoinBalancePriceSimpleView(
              coin: coin ?? cubits.holding.state.holding.coin,
              alt: dollarText,
              //wholeStyle: AppText.wholeHolding,
              //partStyle: AppText.partHolding,
            )
          else
            BlocBuilder<PoolCubit, PoolState>(
                builder: (BuildContext context, PoolState state) {
              return CoinBalanceView(
                coin: (cubits.pool.state.poolStatus == PoolStatus.joined &&
                        cubits.pool.state.isActive)
                    ? cubits.pool.state.poolHolding?.coin ?? Coin()
                    : coin ?? cubits.holding.state.holding.coin,
                //wholeStyle: AppText.wholeHolding,
                //partOneStyle: AppText.partHolding,
                //partTwoStyle: AppText.partHolding,
                //partThreeStyle: AppText.partHolding,
              );
            })
        else ...[
          Text(whole, style: AppText.wholeHolding.copyWith(height: 0)),
          if ((part ?? cubits.holding.state.part) != '')
            Text('.${part ?? cubits.holding.state.part}',
                style: AppText.partHolding.copyWith(height: 0)),
        ]
      ]),
      if (showSubtitle)
        FadeIn(
            child: Text(subtitle,
                textAlign: TextAlign.center,
                style: AppText.usdHolding.copyWith(height: 0))),
      //HighlightedNameView(holding: cubits.holding.state.holding)
      //Text(
      //    subtitle ??
      //        (cubits.holding.state.holding.isCurrency
      //            ? cubits.holding.state.holding.blockchain.chain.title
      //            : cubits.holding.state.holding.name),
      //    style: AppText.usdHolding),
    ]);
  }

  Widget buttons() => SizedBox(
      width: screen.width * .8,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        const SizedBox.shrink(),
        if (cubits.holding.state.holding.sats.value > 0 &&
            (cubits.holding.state.holding.isCurrency ||
                getHoldingOf(cubits.holding.state.holding.blockchain)
                        .sats
                        .value >
                    0))
          assetButton(
            onTap: //!['\$ -', '\$ 0.00'].contains(cubits.holding.state.usd)
                cubits.holding.state.holding.sats.value > 0
                    ? () => maestro.activateSend()
                    : () => cubits.toast.flash(
                          msg: const ToastMessage(
                            duration: Duration(seconds: 2),
                            title: 'Empty',
                            text: 'unable to send',
                          ),
                        ),
            icon: 'outgoing-raw',
            label: 'Send',
          ),
        //SizedBox(width: screen.canvas.wSpace),
        assetButton(
          onTap: () =>
              maestro.activateReceive(cubits.holding.state.holding.blockchain),
          icon: 'incoming-raw',
          label: 'Receive',
        ),
        // POOL NOT READY
        if (false && cubits.holding.state.holding.asset.name.toLowerCase() == 'satori')
          assetButton(
            onTap: () => maestro.activatePoolOnHolding(),
            icon: 'pool',
            label: 'Pool',
          ),
        //SizedBox(width: screen.canvas.wSpace),
        //if (DateTime.now().isAfter(DateTime(2024, 7, 15)))
        //GestureDetector(
        //    onTap: () => maestro.activateSwapOnHolding(),
        //    child:
        //        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        //      Container(
        //        height: screen.iconLarge,
        //        width: screen.iconLarge,
        //        alignment: Alignment.center,
        //        decoration: BoxDecoration(
        //          color: AppColors.buttonLight,
        //          borderRadius: BorderRadius.circular(100),
        //        ),
        //        child: SvgPicture.asset(
        //          '${TransactionIcons.base}/swap.${TransactionIcons.ext}',
        //          alignment: Alignment.center,
        //        ),
        //      ),
        //      const SizedBox(height: 4),
        //      Text('swap', style: AppText.labelHolding),
        //    ])),
        const SizedBox.shrink(),
      ]));

  GestureDetector assetButton({
    required void Function()? onTap,
    required String icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: screen.iconLarge + 12,
            width: screen.iconLarge + 12,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.buttonLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: SvgPicture.asset(
              '${TransactionIcons.base}/$icon.${TransactionIcons.ext}',
              alignment: Alignment.center,
              colorFilter:
                  const ColorFilter.mode(AppColors.white87, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppText.labelHolding),
        ],
      ),
    );
  }

  /// AnimatedPositions solution:
  @override
  Widget build(BuildContext context) => BlocBuilder<HoldingCubit, HoldingState>(
      buildWhen: (HoldingState previous, HoldingState current) =>
          current.active &&
          (previous.section != current.section ||
              previous.holding != current.holding),
      builder: (context, HoldingState state) {
        double modifierTop = 0;
        double iconTop = 16;
        int expandedSpacing = 0;
        int scrunchedSpacing = 0;
        double valueTop = iconTop + screen.iconHuge + expandedSpacing;
        Coin? overrideCoin;
        String? overrideWhole;
        String? overridePart;
        String? overrideSubtitle;

        if (state.section == HoldingSection.none) {
          iconTop = 8;
          valueTop = iconTop + screen.iconHuge + expandedSpacing;
        } else if (state.section == HoldingSection.send) {
          overrideSubtitle = state.holding.isCurrency
              ? (state.holding.blockchain.name)
              : state.holding.name;
          iconTop = screen.canvas.midHeight / 2 - (screen.iconHuge * 1.67);
          valueTop = (screen.canvas.midHeight / 2 - (screen.iconHuge * 1.67)) +
              screen.iconHuge +
              scrunchedSpacing;
        } else if (state.section == HoldingSection.receive) {
          iconTop = screen.canvas.midHeight / 2 - (screen.iconHuge * 1.67);
          valueTop = (screen.canvas.midHeight / 2 - (screen.iconHuge * 1.67)) +
              screen.iconHuge +
              scrunchedSpacing;
          overrideWhole = 'Send to Me';
          overridePart = '';
          overrideSubtitle = state.holding.isCurrency
              ? (state.holding.blockchain.name)
              : state.holding.name;
          //: '${state.holding.name}${'\non ${state.holding.blockchain.name}'}';
        } else if (state.section == HoldingSection.pool) {
          iconTop = screen.canvas.midHeight / 2 - (screen.iconHuge * 1.67);
          valueTop = (screen.canvas.midHeight / 2 - (screen.iconHuge * 1.67)) +
              screen.iconHuge +
              scrunchedSpacing;
          overrideSubtitle = 'Fee: 20%';
        } else if (state.section == HoldingSection.swap) {
          iconTop = screen.canvas.midHeight / 2 - (screen.iconHuge * 1.67);
          valueTop = (screen.canvas.midHeight / 2 - (screen.iconHuge * 1.67)) +
              screen.iconHuge +
              scrunchedSpacing;
          //iconTop = 24;
          //valueTop = 24 + screen.iconHuge + 24;
        } else if (state.section == HoldingSection.transaction) {
          iconTop = screen.canvas.midHeight / 2 - (screen.iconHuge * 1.67);
          valueTop = (screen.canvas.midHeight / 2 - (screen.iconHuge * 1.67)) +
              screen.iconHuge +
              scrunchedSpacing;
          overrideCoin = cubits.holding.state.transaction?.coin;
          //overrideWhole = cubits.holding.state.wholeTransaction;
          //overridePart = cubits.holding.state.partTransaction;
          overrideSubtitle = cubits.holding.state.transaction == null
              ? ''
              : (cubits.holding.state.transaction!.incoming)
                  ? 'Received'
                  : 'Sent';
        }
        if ((overrideSubtitle ?? cubits.holding.state.usd) == '\$ -') {
          modifierTop = 16;
        }
        return Stack(alignment: Alignment.topCenter, children: [
          AnimatedPositioned(
              duration: slideDuration,
              curve: Curves.easeInOutCubic,
              top: modifierTop + iconTop,
              child: assetIcon()),
          AnimatedPositioned(
              duration: slideDuration,
              curve: Curves.easeInOutCubic,
              top: modifierTop + valueTop,
              child: assetValues(
                  coin: overrideCoin,
                  whole: overrideWhole,
                  part: overridePart,
                  subtitle: overrideSubtitle)),
          Positioned(
              bottom: 16,
              child: Hide(
                  hidden: state.section != HoldingSection.none,
                  child: buttons())),
        ]);
      });
}

class TokenToggle extends StatefulWidget {
  final Holding mainHolding;
  final Holding adminHolding;
  final double height;
  final double width;
  final TextStyle style;

  const TokenToggle({
    super.key,
    required this.mainHolding,
    required this.adminHolding,
    required this.height,
    required this.width,
    required this.style,
  });

  @override
  TokenToggleState createState() => TokenToggleState();
}

class TokenToggleState extends State<TokenToggle> {
  bool isAdminSelected = false;

  void _toggleMain() {
    if (isAdminSelected) {
      // TODO: maestro might be locked, could causes issue with widget state
      if (!maestro.locked) {
        maestro.activateOtherHolding(widget.mainHolding);
        setState(() => isAdminSelected = false);
      }
    }
  }

  void _toggleAdmin() {
    if (!isAdminSelected) {
      // TODO: maestro might be locked, could causes issue with widget state
      if (!maestro.locked) {
        maestro.activateOtherHolding(widget.adminHolding);
        setState(() => isAdminSelected = true);
      }
    }
  }

  double? _disapearMain() {
    if (isAdminSelected &&
        cubits.holding.state.section != HoldingSection.none) {
      return 0.0;
    }
    return null;
  }

  double? _disapearAdmin() {
    if (!isAdminSelected &&
        cubits.holding.state.section != HoldingSection.none) {
      return 0.0;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HoldingCubit, HoldingState>(
        buildWhen: (HoldingState previous, HoldingState current) =>
            previous.section != current.section,
        builder: (context, HoldingState state) => SizedBox(
            width: widget.width * 4 + 16 + 12,
            height: widget.height,
            child: Stack(alignment: Alignment.bottomCenter, children: [
              AnimatedPositioned(
                  left: isAdminSelected
                      ? 0 + 12 + 6
                      : widget.width * 1 + 32 + 12 + 6,
                  duration: fadeDuration,
                  curve: Curves.easeInOut,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _toggleMain,
                        child: AnimatedOpacity(
                          opacity:
                              _disapearMain() ?? (isAdminSelected ? 0.38 : 1.0),
                          duration: fadeDuration,
                          child: AnimatedScale(
                            scale: isAdminSelected ? 0.72 : 1.0,
                            duration: fadeDuration,
                            child: SimpleIdenticon(
                              letter: widget.mainHolding.symbol[0],
                              height: widget.height,
                              width: widget.width,
                              style: widget.style,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: _toggleAdmin,
                        child: AnimatedOpacity(
                          opacity: _disapearAdmin() ??
                              (isAdminSelected ? 1.0 : 0.38),
                          duration: fadeDuration,
                          child: AnimatedScale(
                            scale: isAdminSelected ? 1.0 : 0.72,
                            duration: fadeDuration,
                            child: SimpleIdenticon(
                              letter: widget.adminHolding.symbol[0],
                              height: widget.height,
                              width: widget.width,
                              style: widget.style,
                              admin: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))
            ])));
  }
}
