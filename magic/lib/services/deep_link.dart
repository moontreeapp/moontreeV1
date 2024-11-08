import 'package:app_links/app_links.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/services/services.dart';
import 'package:magic/utils/log.dart';
import 'dart:developer';
import 'dart:async';

/// Deep link service class to handle deep links
class DeepLinkService {
  /// Stream subscription
  static StreamSubscription? sub;

  /// Initialize deep link
  static void initDeepLink() {
    try {
      sub = AppLinks().uriLinkStream.listen(
        (Uri uri) {
          see('Applinks got called');
          see('????????????$uri');
          _handleLinks(uri);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        log(
          'Error in initDeepLink: $e',
          name: 'DeepLinkService',
        );
      }
    }
  }

  /// Handle deep link
  static Future<void> _handleLinks(Uri uri) async {
    if (uri.toString().isNotEmpty) {
      final parameters = uri.queryParameters;
      String? address =
          parameters.containsKey('address') ? parameters['address'] : '';
      log(
        '$address =====> URI :: $uri',
        name: 'DeepLinkService',
      );

      if (address != null && address.isNotEmpty) {
        final String coinType = address[0].toLowerCase();

        final Holding? holding = cubits.wallet.state.holdings.firstWhereOrNull(
          (e) => e.blockchain.chain.title.toLowerCase().startsWith(coinType),
        );

        if (holding == null) {
          cubits.toast.flash(
            msg: const ToastMessage(
              text: 'Holding not found, please try again',
            ),
          );
          return;
        }
        await maestro.activateHistory(
          holding: holding,
          redirectOnEmpty: true,
        );
        maestro.activateSend(
          address: address,
          amount: '',
          redirectToPreview: true,
        );
      }
    }
  }

  /// Generate deep link for store
  static String generateReceiveDeepLink({
    required String address,
  }) {
    final Uri deepLink = Uri(
      scheme: 'https',
      host: 'com.magic.mobile',
      queryParameters: {
        'address': address,
      },
    );

    return 'Use this link to directly send to the address:${deepLink.toString()}';
  }
}
