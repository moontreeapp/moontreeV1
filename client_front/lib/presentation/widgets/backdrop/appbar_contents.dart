import 'dart:io' show Platform;
import 'package:client_front/application/cubits.dart';
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/infrastructure/calls/subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:flutter/services.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_front/presentation/components/components.dart';

class BackdropAppBarContents extends StatelessWidget
    implements PreferredSizeWidget {
  final bool spoof;
  final bool animate;

  BackdropAppBarContents({
    Key? key,
    this.spoof = false,
    this.animate = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size(double.infinity, 56);

  @override
  Widget build(BuildContext context) {
    final Widget appBar = Platform.isIOS
        ? buildAppBar(
            context,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark, // For iOS
            ),
            backgroundColor: Colors.transparent,
            shape: components.shape.topRounded8,
          )
        : buildAppBar(
            context,
            backgroundColor: AppColors.primary,
            shape: components.shape.topRounded8,
          );
    /*final Widget  alphaBar = Platform.isIOS
        ? Container(
            height: 56,
            child: ClipRect(
              child: Container(
                alignment: Alignment.topRight,
                child: Banner(
                  message: 'alpha',
                  location: BannerLocation.topEnd,
                  color: AppColors.success,
                ),
              ),
            ))
        : ClipRect(
            child: Container(
              alignment: Alignment.topRight,
              child: Banner(
                message: 'alpha',
                location: BannerLocation.topEnd,
                color: AppColors.success,
              ),
            ),
          );*/
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        if (Platform.isIOS)
          FrontCurve(
            height: 56,
            color: Theme.of(context).backgroundColor,
            fuzzyTop: false,
            frontLayerBoxShadow: const <BoxShadow>[],
          ),
        testAppBar(appBar, test: true),
        // alphaBar,
        const AppBarScrim(),
      ],
    );
  }

/*
Address(id: 3a9261a1367e718ab6f689b12713fe6378373fc5b2b7958134718867b257abd8, address: EarvV1y361BVqpRcyHzi1mabVcGWL7LzpT, walletId: 02ed3aa14d9832d6a6f74ff7967f586472a1388e9a2e972b3b31f9351fef1f5b60, hdIndex: 0, exposure: NodeExposure.external, net: Net.main)
Address(id: 6ba90b238db0181a806affc5c5a787666822376df601d9140d97b96f9dcf6439, address: ESNa5yYTwN2DEhALLW3z6DdbSg9psBoJDK, walletId: 02ed3aa14d9832d6a6f74ff7967f586472a1388e9a2e972b3b31f9351fef1f5b60, hdIndex: 1, exposure: NodeExposure.external, net: Net.main)
Address(id: 501587a63f404e723b6486221b75dd84c75c3234ff6362bbaf48535cf5b724a2, address: EcV164xVxYQL2XJS63JSzAvuHvSuuBT59E, walletId: 02ed3aa14d9832d6a6f74ff7967f586472a1388e9a2e972b3b31f9351fef1f5b60, hdIndex: 2, exposure: NodeExposure.external, net: Net.main)

Address(id: 3a9261a1367e718ab6f689b12713fe6378373fc5b2b7958134718867b257abd8, address: RSzD4x1pFsh9vXBxdczK79vqVEDyb469Uv, walletId: 02ed3aa14d9832d6a6f74ff7967f586472a1388e9a2e972b3b31f9351fef1f5b60, hdIndex: 0, exposure: NodeExposure.external, net: Net.main)
Address(id: 6ba90b238db0181a806affc5c5a787666822376df601d9140d97b96f9dcf6439, address: RJVrfubF7EXsKPvfzq3bBbyqSJ7J8K1uxW, walletId: 02ed3aa14d9832d6a6f74ff7967f586472a1388e9a2e972b3b31f9351fef1f5b60, hdIndex: 1, exposure: NodeExposure.external, net: Net.main)
Address(id: 501587a63f404e723b6486221b75dd84c75c3234ff6362bbaf48535cf5b724a2, address: RUcHg11H8Quz7E4mkNJ45ZH9HYQP6vtEe5, walletId: 02ed3aa14d9832d6a6f74ff7967f586472a1388e9a2e972b3b31f9351fef1f5b60, hdIndex: 2, exposure: NodeExposure.external, net: Net.main)
*/
  Widget testAppBar(Widget appBar, {bool test = false}) => test
      ? GestureDetector(
          onTap: () async {
            if (services.developer.developerMode) {
              //await setupSubscription(wallet: Current.wallet);
              components.cubits.loadingViewCubit
                  .set(status: LoadingStatus.busy);
              //Future.delayed(Duration(seconds: 3), logout);
              for (final x in pros.cache.records) {
                print(x);
              }
              //print(await (Current.wallet as LeaderWallet).roots);
            }
          },
          child: appBar,
        )
      : appBar;

  Widget buildAppBar(
    BuildContext context, {
    SystemUiOverlayStyle? systemOverlayStyle,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) =>
      AppBar(
        systemOverlayStyle: systemOverlayStyle,
        backgroundColor: backgroundColor,
        shape: shape,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: () {
          if (<String>['ChooseMethod', 'Login', 'Setup', 'Backupintro']
                  .contains(streams.app.page.value) ||
              streams.app.lead.value == LeadIcon.none) {
            return null;
          }
          return PageLead();
        }(),
        centerTitle: spoof,
        title: PageTitle(animate: animate),
        actions: <Widget>[
          /// thought it might be nice to have an indicator of which blockchain
          /// is being used, but I think we can make better use of the real
          /// estate by moving the options to the network page, and moving the
          /// validation to during the "connect" process rather than before the
          /// page is shown, so commenting out here for now. instead of the
          /// status light we could show the icon of the current blockchain with
          /// an overlay color of the status. then if the option was on the
          /// network page that would make sense.
          //if (!spoof) ChosenBlockchain(),
          /// this is not needed since we have a shimmer and we'll subtle color
          /// the connection light in the event that we have network activity.
          //if (!spoof) ActivityLight(),
          if (!spoof)
            spoof ? const SpoofedConnectionLight() : const ConnectionLight(),
          if (!spoof) const QRCodeContainer(),
          if (!spoof) const SnackBarViewer(),
          if (!spoof) const SizedBox(width: 6),
          if (!spoof) components.status,
          if (!spoof) const PeristentKeyboardWatcher(),
        ],
      );
}