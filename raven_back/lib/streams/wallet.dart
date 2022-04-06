import 'package:raven_back/raven_back.dart';
import 'package:rxdart/rxdart.dart';

class WalletStreams {
  final replay = replayWallet$;
  final leaderChanges = leaderChanges$;
  final singleChanges = singleChanges$;
  final deriveAddress = BehaviorSubject<DeriveLeaderAddress?>.seeded(null);
  final transactions =
      BehaviorSubject<WalletExposureTransactions?>.seeded(null);
}

final Stream<Wallet> replayWallet$ = ReplaySubject<Wallet>()
  ..addStream(res.wallets.changes
      .where((change) => change is Loaded || change is Added)
      .map((added) => added.data));

final Stream<Change<Wallet>> leaderChanges$ =
    res.wallets.changes.where((change) => change.data is LeaderWallet);

final Stream<Change<Wallet>> singleChanges$ =
    res.wallets.changes.where((change) => change.data is SingleWallet);

class DeriveLeaderAddress {
  final LeaderWallet leader;
  final NodeExposure? exposure;
  final bool justOne;

  DeriveLeaderAddress({
    required this.leader,
    this.exposure,
    this.justOne = false,
  });
}

class WalletExposureTransactions {
  final Address address;
  final Iterable<String> transactionIds;

  WalletExposureTransactions({
    required this.address,
    required this.transactionIds,
  });

  String get key => produceKey(address.walletId, address.exposure);
  static String produceKey(String walletId, NodeExposure exposure) =>
      walletId + exposure.enumString;
}
