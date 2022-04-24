import 'package:flutter/material.dart';
import 'package:intersperse/src/intersperse_extensions.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';
import '../pages/pages.dart';

import '../main.dart';

class ButtonComponents {
  IconButton back(BuildContext context) => IconButton(
      icon: components.icons.back, onPressed: () => Navigator.pop(context));

  Widget actionButton(
    BuildContext context, {
    String? label,
    Widget? disabledIcon,
    String? link,
    @required String? currentLink,
    Map<String, dynamic>? arguments,
    VoidCallback? onPressed,
    VoidCallback? disabledOnPressed,
    FocusNode? focusNode,
    bool enabled = true,
    bool invert = false,
  }) =>
      Expanded(
          child: Container(
        height: MediaQuery.of(context).size.height * (40 / 760),
        child: OutlinedButton(
          focusNode: focusNode,
          onPressed: enabled
              ? (link != null
                  ? () {
                      try {
                        final exitWidget =
                            pages.routes(context)[currentLink]!(context);
                        Navigator.push(
                            context,
                            EnterExitRoute(
                                exitPage: exitWidget,
                                enterPage:
                                    pages.routes(context)[link]!(context)));
                      } catch (_) {
                        Navigator.of(components.navigator.routeContext!)
                            .pushNamed(
                          link,
                          arguments: arguments,
                        );
                      }
                    }
                  : onPressed ?? () {})
              : disabledOnPressed ?? () {},
          style: invert
              ? components.styles.buttons.bottom(context, invert: true)
              : components.styles.buttons.bottom(context, disabled: !enabled),
          child: Text(_labelDefault(label),
              style: enabled
                  ? invert
                      ? Theme.of(context).textTheme.invertButton
                      : null
                  : Theme.of(context).textTheme.disabledButton),
        ),
      ));

  String _labelDefault(String? label) => (label ?? 'Preview').toUpperCase();

  Widget wordButton(
    BuildContext context, {
    required String label,
    VoidCallback? onPressed,
    bool enabled = true,
    bool chosen = false,
    double width = 98,
    int? number,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            height: 24,
            child: Text(
              number?.toString() ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: AppColors.black60),
            )),
        Container(
          height: MediaQuery.of(context).size.height * (32 / 760),
          width: width,
          child: OutlinedButton(
            onPressed: enabled ? onPressed ?? () {} : () {},
            style: chosen
                ? components.styles.buttons.word(context, chosen: true)
                : components.styles.buttons.word(context, chosen: false),
            child: Text(
              label.toLowerCase(),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        )
      ]);

  Widget floatingButtons(
    BuildContext context, {
    required List<Widget> buttons,
    Widget? widthSpacer,
  }) =>
      Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            /*height: MediaQuery.of(context).size.height - 100, // example
          instead of this which causes bottom overflow issues we implemented
          a listener on the keyboard to hide the button if the keyboard is
          visible. Not ideal because you must dismiss the keyboard in order 
          to see the button, but I think its nearer to the Truth. see 
          KeyboardHidesWidget
          */
            ),
        Container(
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IgnorePointer(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 80,
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 16),
                    ...<Widget>[
                      for (var button in buttons) button,
                    ].intersperse(widthSpacer ?? SizedBox(width: 16)),
                    SizedBox(width: 16),
                  ],
                ),
                decoration: BoxDecoration(color: Colors.white),
              ),
            ],
          ),
        ),
      ]);

  Widget layeredButtons(
    BuildContext context, {
    required List<Widget> buttons,
    Widget? widthSpacer,
  }) =>
      Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            /*height: MediaQuery.of(context).size.height - 100, // example
          instead of this which causes bottom overflow issues we implemented
          a listener on the keyboard to hide the button if the keyboard is
          visible. Not ideal because you must dismiss the keyboard in order 
          to see the button, but I think its nearer to the Truth. see 
          KeyboardHidesWidget
          */
            ),
        components.containers.navBar(
          context,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 16),
              ...<Widget>[
                for (var button in buttons) button,
              ].intersperse(widthSpacer ?? SizedBox(width: 16)),
              SizedBox(width: 16),
            ],
          ),
        )
      ]);
}
