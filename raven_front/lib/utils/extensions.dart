import 'package:flutter/material.dart';
import 'package:raven_front/utils/size.dart' as size;
import 'package:raven_front/components/components.dart';

/*
.figma(context)      // for use in builders
.figmaH             // entire screen (sizing)
.figmaW            // entire screen
.figmaSafeHeight  // entire screen minus system toolbar
.figmaAppHeight  // entire scren minus system toolbar and fixed appbar (spacing)
.ofMediaHeight(context)  // for use in builders
.ofMediaWidth(context)  // for use in builders
.ofScreenHeight        // entire screen  
.ofScreenWidth        // entire screen
.ofSafeHeight        // entire screen minus system toolbar
.ofAppHeight        // entire screen minus system toolbar and fixed app bar
*/

extension RelativeHeightDoble on num {
  double figma(BuildContext context) =>
      size.relativeHeight(context, (this / 760));
  double get figmaH =>
      size.relativeHeight(components.navigator.routeContext!, (this / 760));
  double get figmaW =>
      size.relativeWidth(components.navigator.routeContext!, this / 360);
  double get figmaSafeHeight => size.relativeHeight(
        components.navigator.routeContext!,
        (this / 680),
        minus: 24,
      );
  double get figmaAppHeight => size.relativeHeight(
        components.navigator.routeContext!,
        (this / 680),
        minus: (24 + 56),
      );
  double ofMediaHeight(BuildContext context) =>
      size.relativeHeight(context, this);
  double ofMediaHeightMinusNavbar(BuildContext context, {bool tall = true}) =>
      size.relativeHeight(context, this, minus: tall ? 118 : 72);
  double get ofScreenHeight =>
      size.relativeHeight(components.navigator.routeContext!, this);
  double get ofSafeHeight =>
      size.relativeHeight(components.navigator.routeContext!, this, minus: 24);
  double get ofAppHeight => size.relativeHeight(
        components.navigator.routeContext!,
        this,
        minus: (24 + 56),
      );
  double ofMediaWidth(BuildContext context) =>
      size.relativeWidth(context, this);
  double get ofScreenWidth =>
      size.relativeWidth(components.navigator.routeContext!, this);
}
