import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/pool/cubit.dart';
import 'package:magic/cubits/pane/wallet/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/asset_icons.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/ui/canvas/balance/chips.dart';
import 'package:magic/presentation/widgets/assets/amounts.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';
import 'package:magic/services/services.dart';

// TODO: implement chain icons for assets with the same name on different chains
// TODO: This code works but it get's applied to all assets currently. Uncomment
// TODO: this same TODO throughout this file to apply it to all assets.
// enum BlockchainIconSize {
// small,
// extraSmall,
// }

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  WalletPageState createState() => WalletPageState();
}

class WalletPageState extends State<WalletPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Holding> _filteredHoldings = [];

  @override
  void initState() {
    super.initState();
    _filteredHoldings = cubits.wallet.state.holdings
        .where((holding) =>
            Chips.combinedFilter(cubits.wallet.state.chips)(holding))
        .toList();
  }

  void _updateFilteredHoldings() {
    final newFilteredHoldings = cubits.wallet.state.holdings
        .where((holding) =>
            Chips.combinedFilter(cubits.wallet.state.chips)(holding))
        .toList();

    final oldFilteredHoldings = List<Holding>.from(_filteredHoldings);

    _filteredHoldings = newFilteredHoldings;

    final oldIndexMap = Map.fromEntries(oldFilteredHoldings
        .asMap()
        .entries
        .map((e) => MapEntry(e.value, e.key)));

    final itemsToRemove = oldFilteredHoldings
        .where((item) => !newFilteredHoldings.contains(item))
        .toList();
    for (var item in itemsToRemove) {
      int index = oldIndexMap[item] ?? -1;
      if (index != -1) {
        _listKey.currentState?.removeItem(
            index, (context, animation) => _buildItem(item, animation),
            duration: const Duration(milliseconds: 300));
      }
    }

    final newIndexMap = Map.fromEntries(newFilteredHoldings
        .asMap()
        .entries
        .map((e) => MapEntry(e.value, e.key)));
    final itemsToAdd = newFilteredHoldings
        .where((item) => !oldFilteredHoldings.contains(item))
        .toList();
    for (var item in itemsToAdd) {
      int index = newIndexMap[item] ?? -1;
      if (index != -1) {
        _listKey.currentState?.insertItem(index);
      }
    }
  }

  Widget _buildItem(Holding holding, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: HoldingItem(holding: holding),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
        buildWhen: (previous, current) =>
            previous.holdings != current.holdings ||
            previous.chips != current.chips,
        builder: (BuildContext context, WalletState walletState) =>
            BlocBuilder<MenuCubit, MenuState>(
                buildWhen: (previous, current) => previous.mode != current.mode,
                builder: (BuildContext context, MenuState state) {
                  /// all must satisfy
                  //final filtered =
                  //    walletState.holdings.toList(); // Create a copy of the list
                  //filtered.removeWhere((holding) => walletState.chips
                  //    .map((e) => e.filter)
                  //    .any((filter) => !filter(holding)));

                  /// additive - any must satisfy
                  //final filtered = walletState.holdings
                  //    .where((holding) => walletState.chips
                  //        .map((e) => e.filter)
                  //        .any((filter) => filter(holding)))
                  //    .toList();

                  /// smart - depends...
                  if (walletState.holdings.isEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: 3,
                      itemBuilder: (context, index) => HoldingItemPlaceholder(
                        delay: Duration(milliseconds: index * 67),
                      ),
                    );
                  }
                  final filtered = walletState.holdings
                      .where((holding) =>
                          Chips.combinedFilter(walletState.chips)(holding))
                      .toList();

                  return ListView.builder(
                      controller: cubits.pane.state.scroller!,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, int index) {
                        final holding = filtered[index];
                        if (holding.isAdmin && holding.weHaveAdminOrMain) {
                          return const SizedBox(height: 0);
                        }
                        return HoldingItem(holding: holding);
                      });
                }));
    /*BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (previous, current) =>
          previous.holdings != current.holdings ||
          previous.chips != current.chips,
      builder: (BuildContext context, WalletState walletState) =>
          BlocBuilder<MenuCubit, MenuState>(
        buildWhen: (previous, current) => previous.mode != current.mode,
        builder: (BuildContext context, MenuState state) {
          _updateFilteredHoldings();

          /// all must satisfy
          //final filtered =
          //    walletState.holdings.toList(); // Create a copy of the list
          //filtered.removeWhere((holding) => walletState.chips
          //    .map((e) => e.filter)
          //    .any((filter) => !filter(holding)));

          /// additive - any must satisfy
          //final filtered = walletState.holdings
          //    .where((holding) => walletState.chips
          //        .map((e) => e.filter)
          //        .any((filter) => filter(holding)))
          //    .toList();

          /// smart - depends...
          if (walletState.holdings.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: 3,
              itemBuilder: (context, index) => HoldingItemPlaceholder(
                delay: Duration(milliseconds: index * 67),
              ),
            );
          }
          return AnimatedList(
            key: _listKey,
            initialItemCount: _filteredHoldings.length,
            itemBuilder: (context, index, animation) {
              return _buildItem(_filteredHoldings[index], animation);
            },
          );
        },
      ),
    );*/
  }
}

class HoldingItem extends StatelessWidget {
  final Holding holding;

  const HoldingItem({super.key, required this.holding});

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: () =>
            maestro.activateHistory(holding: holding, redirectOnEmpty: true),
        splashColor: Colors.transparent,
        leading: holding.isCurrency
            ? CurrencyIdenticon(holding: holding)
            : AssetIcons.hasCustomIcon(holding.name, holding.blockchain)
                ? AssetIdenticon(holding: holding)
                : SimpleIdenticon(letter: holding.assetPathChildNFT[0]),
        // TODO: implement chain icons for assets with the same name on different chains
        // TODO: This code works but it get's applied to all assets currently.
        // : SimpleIdenticon(
        //     letter: holding.assetPathChildNFT[0],
        //     blockchain: holding.blockchain,
        //     blockchainIconSize: BlockchainIconSize.extraSmall),
        title: SizedBox(
            width: screen.width -
                (screen.iconMedium +
                    screen.iconMedium +
                    screen.iconLarge +
                    24 +
                    24),
            //color: Colors.grey,
            //child: HighlightedNameView(
            //  holding: holding,
            //  parentsStyle: AppText.parentsAssetNameDark,
            //  childStyle: AppText.childAssetNameDark,
            //)),

            child: Text(
                holding.isCurrency
                    ? holding.blockchain.chain.title
                    : holding.assetPathChildNFT,
                style: AppText.body1Front)),
        subtitle: SimpleCoinSplitView(coin: holding.coin, incoming: null),
        trailing: FiatView(fiat: holding.coin.toFiat(holding.rate)),
      );
}

class CurrencyIdenticon extends StatelessWidget {
  final Holding holding;
  final double? height;
  final double? width;

  const CurrencyIdenticon({
    super.key,
    required this.holding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? screen.iconLarge,
      height: height ?? screen.iconLarge,
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        //borderRadius: BorderRadius.circular(100),
      ),
      child: Image.asset(holding.blockchain.logo),
    );
  }
}

class SimpleIdenticon extends StatelessWidget {
  final Color? color;
  final String? letter;
  final double? height;
  final double? width;
  final TextStyle? style;
  final bool showAppIcon;
  //final bool showBlockchainIcon;
  final bool showPoolIndicatorIcon;
  final bool? admin;
  final Blockchain? blockchain;

  // final BlockchainIconSize blockchainIconSize;

  const SimpleIdenticon({
    super.key,
    this.letter,
    this.color,
    this.width,
    this.height,
    this.showAppIcon = false,
    //this.showBlockchainIcon = false,
    this.showPoolIndicatorIcon = false,
    this.style,
    this.admin,
    this.blockchain,
    // this.blockchainIconSize = BlockchainIconSize.small,
  });

  // TODO: implement chain icons for assets with the same name on different chains
  // TODO: This code works but it get's applied to all assets currently.
  // Getter to return the appropriate size
  // double get blockchainIconSizeValue {
  //   switch (blockchainIconSize) {
  //     case BlockchainIconSize.small:
  //       return screen.iconSmall;
  //     case BlockchainIconSize.extraSmall:
  //       return screen.iconExtraSmall;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final chosenLetter =
        letter ?? 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[Random().nextInt(26)];
    final chosenColor = color ??
        //AppColors.identicons[Random().nextInt(AppColors.identicons.length)];
        AppColors.identicons[
            'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890'
                    .indexOf(letter!) %
                AppColors.identicons.length];
    final iconPath = AssetIcons.getIconPath(
      cubits.holding.state.holding.name,
      cubits.holding.state.holding.blockchain,
    );

    final identicon = Container(
      width: width ?? screen.iconLarge,
      height: height ?? screen.iconLarge,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        //color: Colors.amber,
        color: chosenColor,
        shape: BoxShape.circle,
        //border: Border.all(
        //  //color: AppColors.primary, // Replace with your desired border color
        //  width: 2.0,
        //),
      ),
      child: showPoolIndicatorIcon
          ? Image.asset(
              iconPath ?? blockchain!.logo,
            )
          //: showBlockchainIcon
          //    ? Image.asset(
          //        iconPath ?? blockchain!.logo,
          //      )
          : showAppIcon
              ? SvgPicture.asset(
                  LogoIcons.appLogo,
                )
              : Text(chosenLetter, style: style ?? AppText.identiconLarge),
    );
    if (admin == true || blockchain != null) {
      return Stack(
        children: <Widget>[
          identicon,
          if (admin == true)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: screen.iconSmall + 2,
                height: screen.iconSmall + 2,
                alignment: Alignment.bottomCenter,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 1),
                  child: Icon(Icons.star, color: Colors.white, size: 16),
                ),
              ),
            ),
          if (blockchain != null &&
              (showPoolIndicatorIcon &&
                      cubits.pool.state.poolStatus == PoolStatus.joined ||
                  !showPoolIndicatorIcon))
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: showPoolIndicatorIcon
                    ? screen.iconMedium
                    : screen.iconSmall,
                height: showPoolIndicatorIcon
                    ? screen.iconMedium
                    : screen.iconSmall,
                // TODO: implement chain icons for assets with the same name on different chains
                // TODO: This code works but it get's applied to all assets currently.
                // width: blockchainIconSizeValue,
                // height: blockchainIconSizeValue,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: showPoolIndicatorIcon //||showBlockchainIcon
                      ? AppColors.buttonLight
                      : AppColors.background,
                ),
                child: showPoolIndicatorIcon
                    ? SvgPicture.asset(
                        '${TransactionIcons.base}/pool.${TransactionIcons.ext}',
                        height: screen.iconMedium - 10,
                        width: screen.iconMedium - 10,
                      )
                    : Image.asset(
                        showAppIcon
                            ? iconPath ?? blockchain!.logo
                            : blockchain!.logo,
                        width: screen.iconSmall,
                        height: screen.iconSmall,
                        // TODO: implement chain icons for assets with the same name on different chains
                        // TODO: This code works but it get's applied to all assets currently.
                        // width: blockchainIconSizeValue,
                        // height: blockchainIconSizeValue,
                      ),
              ),
            ),
        ],
      );
    }
    return identicon;
  }
}

class AssetIdenticon extends StatelessWidget {
  final Holding holding;
  final double? height;
  final double? width;
  final Blockchain? blockchain;

  const AssetIdenticon({
    super.key,
    required this.holding,
    this.width,
    this.height,
    this.blockchain,
  });

  @override
  Widget build(BuildContext context) {
    final iconPath = AssetIcons.getIconPath(holding.name, holding.blockchain);
    if (iconPath == null) {
      // Fallback to SimpleIdenticon if no custom icon is found
      return SimpleIdenticon(
        letter: holding.assetPathChildNFT[0],
        // TODO: implement chain icons for assets with the same name on different chains
        // TODO: This code works but it get's applied to all assets currently.
        // blockchain: holding.blockchain,
        // blockchainIconSize: BlockchainIconSize.extraSmall,
      );
    }
    final showPoolIndicatorIcon = holding.asset.name.toLowerCase() == 'satori';
    return Stack(
      children: [
        Container(
          width: width ?? screen.iconLarge,
          height: height ?? screen.iconLarge,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            iconPath,
            width: width ?? screen.iconLarge,
            height: height ?? screen.iconLarge,
            fit: BoxFit.contain,
          ),
        ),
        if (blockchain != null ||
            (showPoolIndicatorIcon &&
                    cubits.pool.state.poolStatus == PoolStatus.joined ||
                !showPoolIndicatorIcon))
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: screen.iconSmall,
              height: screen.iconSmall,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: showPoolIndicatorIcon
                    ? AppColors.button
                    : AppColors.background,
              ),
              child: showPoolIndicatorIcon
                  ? SvgPicture.asset(
                      '${TransactionIcons.base}/pool.${TransactionIcons.ext}',
                      height: screen.iconSmall - 5,
                      width: screen.iconSmall - 5,
                    )
                  : Image.asset(
                      blockchain?.logo ?? '',
                      width: screen.iconSmall,
                      height: screen.iconSmall,
                    ),
            ),
          ),
      ],
    );
  }
}

class HoldingItemPlaceholder extends StatefulWidget {
  final Duration delay;

  const HoldingItemPlaceholder({super.key, this.delay = Duration.zero});

  @override
  State<HoldingItemPlaceholder> createState() => _HoldingItemPlaceholderState();
}

class _HoldingItemPlaceholderState extends State<HoldingItemPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });

    _animation = Tween<double>(begin: 0.67, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: screen.iconLarge,
            height: screen.iconLarge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.frontItem.withOpacity(_animation.value),
            ),
          ),
          title: SizedBox(
            width: screen.width -
                (screen.iconMedium +
                    screen.iconMedium +
                    screen.iconLarge +
                    24 +
                    24),
            child: Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.frontItem.withOpacity(_animation.value),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
