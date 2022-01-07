import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/records/records.dart';
import 'package:fnv/fnv.dart';
import 'package:raven_front/services/storage.dart';

import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/widgets/circle_gradient.dart';

class IconComponents {
  IconComponents();

  Icon get back => Icon(Icons.chevron_left_rounded, color: Colors.white);

  Icon income(BuildContext context) =>
      Icon(Icons.south_west, size: 12.0, color: Theme.of(context).good);

  Icon out(BuildContext context) =>
      Icon(Icons.north_east, size: 12.0, color: Theme.of(context).bad);

  Icon importDisabled(BuildContext context) =>
      Icon(Icons.add_box_outlined, color: Theme.of(context).disabledColor);

  Icon get import => Icon(Icons.add_box_outlined);

  Icon get export => Icon(Icons.save);

  Image get assetMasterImage => Image.asset('assets/masterbag_transparent.png');
  Image get assetRegularImage => Image.asset('assets/assetbag_transparent.png');

  Widget assetAvatar(String asset, {double? height, double? width}) {
    if (asset.toUpperCase() == 'RVN') {
      return _assetAvatarRVN(height: height, width: width);
    }
    var ret = _assetAvatarSecurity(asset, height: height, width: width);
    if (ret != null) {
      return ret;
    }
    return _assetAvatarGenerated(asset, height: height, width: width);
  }

  Widget _assetAvatarRVN({double? height, double? width}) => Image.asset(
        'assets/rvn.png',
        height: height,
        width: width,
      );

  /// return custom logo (presumably previously downloaded from ipfs) or null
  Widget? _assetAvatarSecurity(String symbol, {double? height, double? width}) {
    var security =
        securities.bySymbolSecurityType.getOne(symbol, SecurityType.RavenAsset);
    if (security != null &&
        !([null, '']).contains(security.asset?.logo?.data)) {
      try {
        return Image.file(
            AssetLogos().readImageFileNow(security.asset?.logo?.data ?? ''),
            height: height,
            width: width);
        //settings.primaryIndex.getOne(SettingName.Local_Path)!.value
      } catch (e) {
        print(
            'unable to open image asset file for ${security.asset?.logo?.data}: $e');
      }
    }
  }

  /// no logo? no problem, we'll make one...
  /// Remove the `!` when calculating hash, so each master asset
  /// matches its corresponding regular asset autogenerated colors
  Widget _assetAvatarGenerated(String asset, {double? height, double? width}) {
    var i = fnv1a_64(asset.codeUnits);
    if (asset.endsWith('!')) {
      i = fnv1a_64(asset.substring(0, asset.length - 1).codeUnits);
      return Container(
          child: moneybag(gradients[i % gradients.length], assetMasterImage),
          height: height,
          width: width);
    }
    return Container(
        child: moneybag(gradients[i % gradients.length], assetRegularImage),
        height: height,
        width: width);
  }

  // replace with the new thing...
  Widget moneybag(ColorPair background, Image foreground) =>
      Stack(children: [PopCircle(colorPair: background), foreground]);

  CircleAvatar appAvatar() =>
      CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

  CircleAvatar accountAvatar() =>
      CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

  CircleAvatar walletAvatar(Wallet wallet) => wallet is LeaderWallet
      ? CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'))
      : CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));
}
