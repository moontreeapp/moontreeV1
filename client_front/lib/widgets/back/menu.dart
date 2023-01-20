import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/consent.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/theme/theme.dart';
import 'package:client_front/utils/auth.dart';
import 'package:client_front/utils/extensions.dart';
import 'package:client_front/services/services.dart';

import 'package:client_front/services/lookup.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:client_front/utils/zips.dart';
//import 'package:client_front/theme/extensions.dart';
//import 'package:client_back/utilities/database.dart' as ravenDatabase;

class NavMenu extends StatefulWidget {
  const NavMenu({Key? key}) : super(key: key);

  @override
  _NavMenuState createState() => _NavMenuState();
}

class _NavMenuState extends State<NavMenu> {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  String? chosen = '/settings';

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.setting.listen((String? value) {
      if (value != chosen) {
        setState(() {
          chosen = value;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  Widget destination({
    required String name,
    required String link,
    IconData? icon,
    Image? image,
    bool arrow = false,
    Map<String, dynamic>? arguments,
    Function? execute,
    Function? executeAfter,
    bool disabled = false,
  }) =>
      ListTile(
        onTap: disabled
            ? () {}
            : () {
                if (execute != null) {
                  execute();
                }
                if (!arrow) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  Navigator.of(components.routes.routeContext!).pushNamed(
                    link,
                    arguments: arguments,
                  );

                  /// moved to loader in case we come back to holdings list
                  /// but generally we want to come back to the settings if
                  /// we came from it:
                  //streams.app.setting.add(null);
                  //streams.app.fling.add(false);
                } else {
                  streams.app.setting.add(link);
                }
                if (executeAfter != null) {
                  executeAfter();
                }
              },
        leading: icon != null
            ? Icon(icon, color: disabled ? AppColors.white60 : Colors.white)
            : image!,
        title: Text(name,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: disabled ? AppColors.white60 : AppColors.white)),
        trailing: arrow
            ? Icon(Icons.chevron_right,
                color: disabled ? AppColors.white60 : Colors.white)
            : null,
      );

  @override
  Widget build(BuildContext context) {
    final Map<String, ListView> options = <String, ListView>{
      '/settings/import_export': ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          destination(
              icon: MdiIcons.keyPlus, name: 'Import', link: '/settings/import'),
          destination(
              icon: MdiIcons.keyMinus,
              name: 'Export',
              link: '/settings/export',
              disabled: !services.developer.advancedDeveloperMode),
          if (services.developer.developerMode &&
              (pros.securities.currentCoin.balance?.value ?? 0) > 0)
            destination(
              icon: MdiIcons.broom,
              name: 'Sweep',
              link: '/settings/sweep',
            ),
        ],
      ),
      '/settings/settings': ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          destination(
            icon: Icons.lock_rounded,
            name: 'Security',
            link: '/security/method/change',
          ),
          /*
          if (!pros.settings.authMethodIsNativeSecurity)
            destination(
              icon: Icons.lock_rounded,
              name: 'Password',
              link: '/security/password/change',
            ),
            */
          /*
          destination(
              icon: MdiIcons.accountCog,
              name: 'User Level',
              link: '/settings/level'),
          
          destination( // has been combined with blockchain
            icon: MdiIcons.network,
            name: 'Network',
            link: '/settings/network',
          ),
          */
          if (services.developer.advancedDeveloperMode)
            destination(
              icon: Icons.format_list_bulleted_rounded,
              name: 'Addresses',
              link: '/addresses',
            ),
          destination(
            icon: MdiIcons.pickaxe,
            name: 'Mining',
            link: '/settings/network/mining',
          ),
          if (services.developer.developerMode)
            destination(
              icon: MdiIcons.database,
              name: 'Database',
              link: '/settings/database',
            ),
          if (services.developer.advancedDeveloperMode == true)
            destination(
              icon: MdiIcons.rocketLaunchOutline,
              name: 'Advanced',
              link: '/settings/advanced',
            ),
          destination(
            icon: MdiIcons.devTo,
            name: 'Developer',
            link: '/settings/developer',
          ),
        ],
      ),
      '/settings': ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          destination(
            icon: MdiIcons.linkBoxVariant, //MdiIcons.linkVariant,
            name: 'Blockchain',
            link: '/settings/network/blockchain',
          ),
          if (!services.developer.developerMode)
            destination(
                icon: MdiIcons.shieldKey,
                name: 'Import',
                link: '/settings/import'),
          if (!services.developer.developerMode && Current.balanceRVN.value > 0)
            destination(
              icon: MdiIcons.broom,
              name: 'Sweep',
              link: '/settings/sweep',
            ),
          if (services.developer.developerMode)
            destination(
              icon: MdiIcons.shieldKey,
              name: 'Import & Export',
              link: '/settings/import_export',
              arrow: true,
            ),
          destination(
            icon: MdiIcons.drawPen,
            name: 'Backup',
            link: Current.wallet is LeaderWallet
                ? '/security/backup'
                : '/security/backupKeypair',
          ),
          destination(
            icon: Icons.settings,
            name: 'Settings',
            link: '/settings/settings',
            arrow: true,
          ),
          /*
          destination(
            icon: Icons.feedback,
            name: 'Feedback',
            link: '/settings/feedback',
          ),
          */
          destination(
            icon: Icons.help,
            name: 'Support',
            link: '/settings/support',
          ),
          destination(
            icon: Icons.info_rounded,
            name: 'About',
            link: '/settings/about',
          ),

          /*
          destination(
              icon: Icons.info_outline_rounded,
              name: 'Clear Database',
              link: '/home',
              execute: ravenDatabase.deleteDatabase),
          ListTile(
              title: Text('test'),
              leading: Icon(Icons.info_outline_rounded),
              onTap: () async {
                
              }),
          */
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style:
                  Theme.of(components.routes.routeContext!).textTheme.bodyText2,
              children: <TextSpan>[
                TextSpan(
                    text: 'User Agreement',
                    style: Theme.of(components.routes.routeContext!)
                        .textTheme
                        .underlinedMenuLink,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            documentEndpoint(ConsentDocument.user_agreement)));
                      }),
                const TextSpan(text: '   '),
                TextSpan(
                    text: 'Privacy Policy',
                    style: Theme.of(components.routes.routeContext!)
                        .textTheme
                        .underlinedMenuLink,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            documentEndpoint(ConsentDocument.privacy_policy)));
                      }),
                const TextSpan(text: '   '),
                TextSpan(
                    text: 'Risk Disclosure',
                    style: Theme.of(components.routes.routeContext!)
                        .textTheme
                        .underlinedMenuLink,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(documentEndpoint(
                            ConsentDocument.risk_disclosures)));
                      }),
              ],
            ),
          )
        ],
      )
    };
    return Container(
        color: Theme.of(context).backgroundColor,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(children: <Widget>[
                if (pros.wallets.length > 1)
                  const Divider(indent: 0, color: AppColors.white12),
                (options[chosen] ?? options['/settings'])!
              ]),
              if (services.password.required)
                Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            children: <Widget>[logoutButton],
                          )),
                      SizedBox(height: .065.ofMediaHeight(context) + 16)
                    ])
              else
                Container(),
            ]));
  }

  Widget get logoutButton => components.buttons.actionButton(
        context,
        label: 'Logout',
        invert: true,
        onPressed: logout,
      );
}