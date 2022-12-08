import 'package:flutter/material.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/records/asset.dart' as asset_record;
import 'package:ravencoin_front/components/components.dart';

class AssetPage extends StatefulWidget {
  const AssetPage() : super();

  @override
  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  Map<String, dynamic> data = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    final String symbol = data['symbol'] as String;
    final Asset chosenAsset = pros.assets.primaryIndex
        .getOne(symbol, pros.settings.chain, pros.settings.net)!;
    return BackdropLayers(
      back: CoinSpec(
          pageTitle: 'Asset',
          security: pros.securities.primaryIndex.getOne(
            symbol,
            pros.settings.chain,
            pros.settings.net,
          )!),
      front: FrontCurve(
          height: MediaQuery.of(context).size.height * .64,
          child: Column(children: <Widget>[
            Expanded(child: AssetDetails(symbol: symbol)),
            NavBar(
              placeholderManage: !services.developer.developerMode,
              includeSectors: false,
              actionButtons: <Widget>[
                if (<AssetType>[AssetType.main, AssetType.sub]
                    .contains(chosenAsset.assetType)) ...<Widget>[
                  components.buttons.actionButton(context,
                      label: 'create', onPressed: _produceSubCreateModal),
                ],
                if (<AssetType>[
                  AssetType.qualifier,
                  AssetType.qualifierSub,
                ].contains(chosenAsset.assetType)) ...<Widget>[
                  components.buttons.actionButton(context,
                      label: 'create',
                      onPressed: () => Navigator.pushNamed(
                            components.navigator.routeContext!,
                            '/create/qualifiersub',
                            arguments: <String, String>{
                              'symbol': 'QualifierSub'
                            },
                          )),
                ],
                components.buttons.actionButton(context, label: 'manage',
                    onPressed: () {
                  // if main do this
                  _produceMainManageModal(chosenAsset);
                  // if sub do this
                  //_produceSubManageModal();
                  // if other do this
                  //
                }),
              ],
            )
          ])),
    );
  }

  void _produceSubCreateModal() {
    SelectionItems(context, modalSet: SelectionSet.Sub_Asset).build();
  }

  Future<void> _produceMainManageModal(asset_record.Asset asset) async {
    if (asset.reissuable &&
        <AssetType>[AssetType.main, AssetType.sub, AssetType.restricted]
            .contains(asset.assetType)) {
      await SelectionItems(
        context,
        //symbol: symbol,
        modalSet: SelectionSet.MainManage,
        behaviors: <void Function()>[
          () {
            Navigator.pushNamed(
              context,
              '/reissue/${asset.assetType.name.toLowerCase()}',
              arguments: <String, String>{'symbol': asset.symbol},
            );
          },
          () {
            ///Navigator.pushNamed(
            ///  context,
            ///  '/issue/dividend' + assetType.name.toLowerCase(),
            ///  arguments: {'symbol': symbol},
            ///);
          },
        ],
      ).build();
    }
  }
}
