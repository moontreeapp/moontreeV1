import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/pages/wallet/transactions/components.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc.dart';

double minHeight = 0.65.figmaAppHeight;

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  late List<StreamSubscription> listeners = [];
  DraggableScrollableController dController = DraggableScrollableController();
  @override
  void initState() {
    super.initState();
    transactionsBloc.reset();

    /// need these until we make it fully reactive so we can reset the page if underlying data changes
    listeners.add(res.balances.batchedChanges.listen((batchedChanges) {
      if (batchedChanges.isNotEmpty) {
        print('Refresh - balances');
        setState(() {});
      }
    }));
    listeners.add(streams.client.busy.listen((bool value) {
      if (!value) {
        // todo: value != v so it doesnt' refresh at first each time.
        print('Refresh - busy');
        setState(() {});
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  TransactionsBloc get bloc => transactionsBloc;

  @override
  Widget build(BuildContext context) {
    bloc.data = populateData(context, bloc.data);
    minHeight = !Platform.isIOS
        ? 0.65.figmaAppHeight + (bloc.nullCacheView ? 0 : 48.ofAppHeight)
        : 0.63.figmaAppHeight + (bloc.nullCacheView ? 0 : 48.ofAppHeight);
    return BackdropLayers(
      back: CoinDetailsHeader(bloc.security, minHeight, bloc.nullCacheView),
      front: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          DraggableScrollableSheet(
              initialChildSize: minHeight,
              minChildSize: minHeight,
              maxChildSize: min(1.0, max(minHeight, getMaxExtent(context))),
              controller: dController,
              builder: (context, scrollController) {
                bloc.scrollObserver.add(dController.size);
                return CoinDetailsGlidingSheet(
                  bloc.nullCacheView ? null : MetadataView(),
                  dController,
                  scrollController,
                );
              }),
          AssetNavbar()
        ],
      ),
    );
  }

  double getMaxExtent(BuildContext context) {
    return (bloc.currentTxs.length * 80 +
            80 +
            40 +
            (!services.download.history.isComplete ? 80 : 0))
        .ofMediaHeight(context);
  }
}