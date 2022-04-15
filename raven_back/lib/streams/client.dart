import 'package:rxdart/rxdart.dart';

import 'package:raven_electrum/raven_electrum.dart';

class ClientStreams {
  final client = BehaviorSubject<RavenElectrumClient?>();
  final connected =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected);
}

enum ConnectionStatus { connected, connecting, disconnected }
