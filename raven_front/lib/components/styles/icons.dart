import 'package:flutter/material.dart';
import 'package:raven_mobile/components/styles/colors.dart';

Icon backIcon() => Icon(Icons.arrow_back, color: Colors.grey[100]);
Icon inIcon() => Icon(Icons.south_west, size: 12.0, color: RavenColor().good);
Icon outIcon() => Icon(Icons.north_east, size: 12.0, color: RavenColor().bad);
AssetImage assetIcon(String name) =>
    {'RVN': AssetImage('assets/rvnhead.png')}[name] ??
    AssetImage('assets/defaultasset.png');
CircleAvatar assetAvatar(String name) => CircleAvatar(
      backgroundImage: assetIcon(name),
    );

class RavenIcon {
  RavenIcon();

  Icon get back => backIcon();
  Icon get income => inIcon();
  Icon get out => outIcon();
  AssetImage getAssetImage(String name) => assetIcon(name);
  CircleAvatar getAssetAvatar(String name) => assetAvatar(name);
}
