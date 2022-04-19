import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';

class HomePage extends StatefulWidget {
  final AppContext appContext;

  const HomePage({Key? key, required this.appContext}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late List listeners = [];
  //static const double minExtent = .0736842105263158;
  double minExtent = 1.0;
  static const double maxExtent = 1.0;
  static const double initialExtent = maxExtent;
  late DraggableScrollableController draggableScrollController =
      DraggableScrollableController();
  ScrollController? _scrollController;
  ValueNotifier<double> _notifier = ValueNotifier(1);

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.fling.listen((bool? value) async {
      if (value != null) {
        await fling(value == false ? value : null);
        streams.app.fling.add(null);
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
  Widget build(BuildContext context) {
    //minExtent = 1-(MediaQuery.of(context).size.height - 56)  // pix
    return BackdropLayers(
      back: NavMenu(),
      front: DraggableScrollableActuator(
        child: DraggableScrollableSheet(
          controller: draggableScrollController,
          snap: true,
          initialChildSize: initialExtent,
          minChildSize: minExtent,
          maxChildSize: maxExtent,
          builder: ((context, scrollController) {
            var ignoring = false;
            if (draggableScrollController.size == minExtent &&
                minExtent < 1.0) {
              streams.app.setting.add('/settings');
              ignoring = true;
            } else if (draggableScrollController.size == maxExtent) {
              streams.app.setting.add(null);
            }
            _notifier.value = draggableScrollController.size;
            _scrollController = scrollController;
            return FrontCurve(
                fuzzyTop: true,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    IgnorePointer(
                      ignoring: ignoring,
                      child: AllAssetsHome(
                        scrollController: scrollController,
                        appContext: widget.appContext,
                        placeholderManage: false,
                        placeholderSwap: true,
                      ),
                    ),
                    BottomNavBar(
                      appContext: widget.appContext,
                      dragController: draggableScrollController,
                      notifier: _notifier,
                      placeholderManage: false,
                      placeholderSwap: true,
                    ),
                  ],
                ));
          }),
        ),
      ),
    );
  }

  Future<void> fling([bool? open]) async {
    if ((open ?? false)) {
      await flingDown();
    } else if (!(open ?? true)) {
      await flingUp();
    } else if (await draggableScrollController.size >=
        (maxExtent + minExtent) / 2) {
      await flingDown();
    } else {
      await flingUp();
    }
  }

  Future<void> flingDown() async {
    setState(() {
      minExtent = .10;
    });
    _scrollController!.jumpTo(_scrollController!.position.minScrollExtent);
    await draggableScrollController.animateTo(
      minExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCirc,
    );
  }

  Future<void> flingUp() async {
    streams.app.setting.add(null);
    await draggableScrollController.animateTo(
      maxExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCirc,
    );
    setState(() {
      minExtent = 1.0;
    });
  }
}
/* we want to hide the nav bar if we open the menu, so we can put this on a 
scaffold to do it, or we can do what is above: push it down w/ the front sheet.
NotificationListener<UserScrollNotification>(
                onNotification: visibilityOfSendReceive,
                child: currentContext == AppContext.wallet
                    ? HoldingList()
                    : currentContext == AppContext.manage
                        ? AssetList()
                        : Text('swap'))),
        floatingActionButton:
            SlideTransition(position: offset, child: NavBar()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );

  bool visibilityOfSendReceive(notification) {
    if (notification.direction == ScrollDirection.forward &&
        controller.status == AnimationStatus.completed) {
      controller.reverse();
    } else if (notification.direction == ScrollDirection.reverse &&
        controller.status == AnimationStatus.dismissed) {
      ScaffoldMessenger.of(context).clearSnackBars();
      controller.forward();
    }
    return true;
  }
*/

/*
we should be able to use this to apply a scrim to the front layer
  Widget _buildInactiveLayer(BuildContext context) {
    return Offstage(
      offstage: animationController.status == AnimationStatus.completed,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(animationController),
        child: GestureDetector(
          onTap: () => fling(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: widget.frontLayerScrim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  */

class BottomNavBar extends StatelessWidget {
  final DraggableScrollableController dragController;
  final AppContext appContext;
  final ValueNotifier<double> notifier;
  final bool placeholderManage;
  final bool placeholderSwap;

  const BottomNavBar({
    required this.appContext,
    required this.dragController,
    required this.notifier,
    this.placeholderManage = false,
    this.placeholderSwap = false,
    Key? key,
  }) : super(key: key);

  void _produceCreateModal(BuildContext context) {
    SelectionItems(context, modalSet: SelectionSet.Create).build();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0.0, 100 * (1 - dragController.size) * 1.50),
          child: Container(
              child: NavBar(
            actionButtons: appContext == AppContext.wallet
                ? <Widget>[
                    components.buttons.actionButton(
                      context,
                      label: 'send',
                      onPressed: () {
                        Navigator.of(components.navigator.routeContext!)
                            .pushNamed('/transaction/send');
                        if (Current.wallet is LeaderWallet &&
                            streams.app.triggers.value ==
                                ThresholdTrigger.backup &&
                            !(Current.wallet as LeaderWallet).backedUp) {
                          streams.app.xlead.add(true);
                          Navigator.of(components.navigator.routeContext!)
                              .pushNamed('/security/backup');
                        }
                      },
                    ),
                    components.buttons.actionButton(
                      context,
                      label: 'receive',
                      onPressed: () {
                        Navigator.of(components.navigator.routeContext!)
                            .pushNamed('/transaction/receive');
                        if (Current.wallet is LeaderWallet &&
                            streams.app.triggers.value ==
                                ThresholdTrigger.backup &&
                            !(Current.wallet as LeaderWallet).backedUp) {
                          streams.app.xlead.add(true);
                          Navigator.of(components.navigator.routeContext!)
                              .pushNamed('/security/backup');
                        }
                      },
                    )
                  ]
                : appContext == AppContext.manage
                    ? <Widget>[
                        components.buttons.actionButton(
                          context,
                          label: 'create',
                          enabled: !placeholderManage,
                          onPressed: () {
                            _produceCreateModal(context);
                          },
                        )
                      ]
                    : <Widget>[
                        components.buttons.actionButton(
                          context,
                          label: 'buy',
                          enabled: !placeholderSwap,
                          onPressed: () {
                            _produceCreateModal(context);
                          },
                        ),
                        components.buttons.actionButton(
                          context,
                          label: 'sell',
                          enabled: !placeholderSwap,
                          onPressed: () {
                            _produceCreateModal(context);
                          },
                        )
                      ],
          )),
        );
      },
    );
  }
}

class AllAssetsHome extends StatelessWidget {
  final ScrollController scrollController;
  final AppContext appContext;
  final bool placeholderManage;
  final bool placeholderSwap;

  const AllAssetsHome({
    required this.scrollController,
    required this.appContext,
    this.placeholderManage = false,
    this.placeholderSwap = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: appContext == AppContext.wallet
          ? HoldingList(scrollController: scrollController)
          : appContext == AppContext.manage
              ? placeholderManage
                  ? ComingSoonPlaceholder(
                      scrollController: scrollController,
                      message: 'Create & Manage Assets')
                  : AssetList(scrollController: scrollController)
              : placeholderSwap
                  ? ComingSoonPlaceholder(
                      scrollController: scrollController,
                      message: 'Decentralized Asset Swaps',
                      swap: true)
                  : ListView(
                      controller: scrollController,
                      children: [
                        Text('swap\n\n\n\n\n\n\n\n\n\n\n\n'),
                      ],
                    ),
    );
  }
}
