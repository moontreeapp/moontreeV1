import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

class NavBar extends StatefulWidget {
  NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    var assetType = Asset.assetTypeOf(streams.app.asset.value ?? '');
    return Container(
      height: 118,
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // we will need to make these buttons dependant upon the navigation
          // of the front page through streams but for now, we'll show they
          // can changed based upon whats selected:
          streams.app.context.value == AppContext.wallet
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    components.buttons.actionButton(
                      context,
                      label: 'send',
                      link: '/transaction/send',
                      icon: Icon(MdiIcons.arrowTopRightThick),
                    ),
                    SizedBox(width: 16),
                    components.buttons.actionButton(
                      context,
                      label: 'receive',
                      link: '/transaction/receive',
                      icon: Icon(MdiIcons.arrowBottomLeftThick),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: streams.app.page.value == 'Wallet'
                      ? <Widget>[
                          components.buttons.actionButton(
                            context,
                            label: 'create',
                            icon: Icon(MdiIcons.plus),
                            onPressed: _produceCreateModal,
                          )
                        ]
                      : <Widget>[
                          if ([AssetType.Main, AssetType.Sub]
                              .contains(assetType)) ...[
                            components.buttons.actionButton(context,
                                label: 'create',
                                icon: Icon(MdiIcons.plus),
                                onPressed: streams.app.page.value == 'Asset'
                                    ? _produceSubCreateModal
                                    : () {}),
                            SizedBox(width: 16)
                          ],
                          if ([
                            AssetType.Qualifier,
                            AssetType.QualifierSub,
                          ].contains(assetType)) ...[
                            components.buttons.actionButton(context,
                                label: 'create',
                                icon: Icon(MdiIcons.plus),
                                onPressed: streams.app.page.value == 'Asset'
                                    //? _produceSubQualifierModal
                                    ? () => Navigator.pushNamed(
                                          components.navigator.routeContext!,
                                          '/create/qualifiersub',
                                          arguments: {'symbol': 'QualifierSub'},
                                        )
                                    : () {}),
                            SizedBox(width: 16)
                          ],
                          components.buttons.actionButton(context,
                              label: 'manage',
                              icon: Icon(MdiIcons.circleEditOutline),
                              onPressed: () {/* bring up options */}),
                        ],
                ),
          Padding(
              padding: EdgeInsets.only(left: 32, right: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  sectorIcon(appContext: AppContext.wallet),
                  sectorIcon(appContext: AppContext.manage),
                  sectorIcon(appContext: AppContext.swap),
                ],
              ))
        ],
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
                color: const Color(0x33000000),
                offset: Offset(0, 5),
                blurRadius: 5),
            BoxShadow(
                color: const Color(0x1F000000),
                offset: Offset(0, 3),
                blurRadius: 14),
            BoxShadow(
                color: const Color(0x3D000000),
                offset: Offset(0, 8),
                blurRadius: 10)
          ]),
    );
  }

  Widget sectorIcon({required AppContext appContext}) => IconButton(
        onPressed: () {
          Navigator.of(components.navigator.routeContext!).pushNamed('/home');
          setState(() {
            streams.app.context.add(appContext);
          });
        },
        icon: Icon({
          AppContext.wallet: MdiIcons.wallet,
          AppContext.manage: MdiIcons.plusCircle,
          AppContext.swap: MdiIcons.swapHorizontalBold,
        }[appContext]!),
        iconSize: streams.app.context.value == appContext ? 30 : 24,
        color: streams.app.context.value == appContext
            ? Color(0xFF5C6BC0)
            : Color(0x995C6BC0),
      );

  void _produceCreateModal() {
    SelectionItems(context, modalSet: SelectionSet.Create).build();
  }

  void _produceSubCreateModal() {
    SelectionItems(context, modalSet: SelectionSet.Sub_Asset).build();
  }
}
