import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

class PageStructure extends StatelessWidget {
  final List<Widget> children;
  final List<Widget>? firstLowerChildren;
  final List<Widget>? secondLowerChildren;
  final List<Widget>? thirdLowerChildren;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final double headerSpace;
  final Widget? heightSpacer;
  final Widget? widthSpacer;
  const PageStructure({
    super.key,
    required this.children,
    this.firstLowerChildren,
    this.secondLowerChildren,
    this.thirdLowerChildren,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.headerSpace = 0,
    this.heightSpacer = const SizedBox(height: 16),
    this.widthSpacer = const SizedBox(width: 16),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        behavior: HitTestBehavior.translucent,
        child: Container(
            padding: EdgeInsets.only(
                left: 16, right: 16, top: 16 + headerSpace, bottom: 40),
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Column(
                        mainAxisAlignment:
                            mainAxisAlignment ?? MainAxisAlignment.start,
                        crossAxisAlignment:
                            crossAxisAlignment ?? CrossAxisAlignment.center,
                        children: <Widget>[
                      for (final child in (heightSpacer == null
                          ? children
                          : children.intersperse(heightSpacer!)))
                        child
                    ])),
                if (firstLowerChildren != null)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: <Widget>[
                        for (final Widget child in (widthSpacer == null
                            ? firstLowerChildren!
                            : firstLowerChildren!.intersperse(widthSpacer!)))
                          if (child == widthSpacer)
                            child
                          else
                            Expanded(child: child)
                      ]),
                      if (secondLowerChildren != null)
                        heightSpacer ?? const SizedBox(height: 16),
                      if (secondLowerChildren != null)
                        Row(children: <Widget>[
                          for (final child in (widthSpacer == null
                              ? secondLowerChildren!
                              : secondLowerChildren!.intersperse(widthSpacer!)))
                            if (child == widthSpacer)
                              child
                            else
                              Expanded(child: child)
                        ]),
                      if (thirdLowerChildren != null)
                        heightSpacer ?? const SizedBox(height: 16),
                      if (thirdLowerChildren != null)
                        Row(children: <Widget>[
                          for (final child in (widthSpacer == null
                              ? thirdLowerChildren!
                              : thirdLowerChildren!.intersperse(widthSpacer!)))
                            if (child == widthSpacer)
                              child
                            else
                              Expanded(child: child)
                        ]),
                    ],
                  )
              ],
            )));
  }
}
/*
PageStructure(
  children: <Widget>[
  ],
  firstLowerChildren: <Widget>[
  ],
);
*/