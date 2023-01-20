import 'dart:async';

import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';

class QueueService {
  bool updated = false;
  Set<Address> addresses = <Address>{};
  Address? address;
  List<Set<String>> transactions = <Set<String>>[];
  Set<String>? transactionSet;
  Set<String> dangling = <String>{};

  static const Duration queueTimer = Duration(seconds: 1);
  StreamSubscription<dynamic>? periodic;

  void retry() => periodic == null
      ? periodic =
          Stream<dynamic>.periodic(queueTimer).listen((_) async => process())
      : () {};

  Future<void> reset() async {
    await periodic?.cancel();
    periodic = null;
    dangling.clear();
    streams.client.queue.add(false);
    streams.client.busy.add(false);
    streams.client.activity.add(ActivityMessage());
  }

  Future<void> update({
    Address? address,
    Set<String>? txids,
    bool processToo = true,
  }) async {
    updated = true;
    dangling.add('this item represents dangling transactions on frontend');
    if (address != null) {
      if (transactions.isEmpty && addresses.isEmpty) {
        services.download.history.calledAllDoneProcess = 0;
      }
      addresses.add(address);
      streams.client.queue.add(true);
    }
    if (txids != null && txids.isNotEmpty) {
      if (transactions.isEmpty && addresses.isEmpty) {
        services.download.history.calledAllDoneProcess = 0;
      }
      transactions.add(txids);
      streams.client.queue.add(true);
    }
    if (processToo) {
      unawaited(process());
    }
  }

  Future<void> process() async {
    // todo: only process if idle.
    if ((transactions.isEmpty && addresses.isEmpty) ||
        services.wallet.currentWallet.minerMode) {
      await reset();
      return;
    }
    if (transactionSet != null ||
        address != null ||
        services.client.subscribe.startupProcessRunning ||
        services.wallet.leader.newLeaderProcessRunning ||
        services.download.history.busy) {
      retry();
      return;
    }
    if (!streams.client.busy.value) {
      streams.client.busy.add(true);
    }
    if (transactions.isNotEmpty) {
      streams.client.queue.add(true);
      transactionSet = transactions.first;
      transactions.remove(transactionSet);
      await downloadTransactions();
    } else if (addresses.isNotEmpty) {
      streams.client.queue.add(true);
      address = addresses.first;
      addresses.remove(address);
      await downloadAddress();
    }
  }

  Future<void> downloadTransactions() async {
    await services.download.history.getAndSaveTransactions(transactionSet!);
    transactionSet = null;
    await resetOrProcess();
  }

  Future<void> downloadAddress() async {
    await services.download.history.getTransactions(
      await services.download.history.getHistory(address!),
    );
    address = null;
    await resetOrProcess();
  }

  Future<void> resetOrProcess() async {
    if (transactions.isEmpty && addresses.isEmpty) {
      await services.download.history.allDoneProcess();
      streams.app.wallet.refresh.add(true);
      if (pros.transactions.records.isNotEmpty) {
        services.download.overrideGettingStarted = false;
        streams.app.snack
            .add(Snack(message: 'Transaction history successfully downloaded'));
      }
      await reset();
    } else {
      await process();
    }
  }
}