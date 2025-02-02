import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/balance/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/cubit.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/canvas/balance/chips.dart';
import 'package:magic/presentation/ui/canvas/balance/wallet.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/services/services.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({super.key});

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
          child: const AnimatedBalance()));
}

class AnimatedBalance extends StatelessWidget {
  const AnimatedBalance({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<BalanceCubit, BalanceState>(
      buildWhen: (BalanceState previous, BalanceState current) =>
          current.active,
      builder: (context, state) => BlocBuilder<PaneCubit, PaneState>(
          buildWhen: (PaneState previous, PaneState current) =>
              previous.height != current.height,
          builder: (BuildContext paneContext, PaneState paneState) =>
              AnimatedOpacity(
                  duration: fadeDuration,
                  curve: Curves.easeInOutCubic,
                  opacity: paneState.height == screen.pane.minHeight ? .12 : 1,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedOpacity(
                            duration: fadeDuration,
                            curve: Curves.easeInOutCubic,
                            opacity: paneState.height == screen.pane.minHeight
                                ? 0
                                : 1,
                            child: const WalletChooser()),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    subscription.ensureConnected().then((_) {
                                      //subscription.setupSubscriptions(cubits.keys.master);
                                      cubits.wallet
                                          .populateAssets()
                                          .then((_) => maestro.activateHome());
                                    });
                                  },
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('\$${state.portfolioValue.head}',
                                            style: AppText.wholeFiat),
                                        if (state.portfolioValue.tail !=
                                                '.00' &&
                                            state.portfolioValue.head != '-')
                                          Text(state.portfolioValue.tail,
                                              style: AppText.partFiat),
                                      ])),
                              Text('Portfolio', style: AppText.usdHolding),
                            ]),
                        Visibility(
                          visible: paneState.height != screen.pane.minHeight,
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: true,
                          child: const ChipsView(),
                        ),
                      ]))));
}
