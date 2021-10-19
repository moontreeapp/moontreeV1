/// this waiter subscribes to blockchain updates such as blockheaders
/// using electrum client.
/// if block headers was not a subscribe, but a function we could call on
/// demand I believe we could save the electrumx server some bandwidth costs...

import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';
import 'waiter.dart';

class BlockWaiter extends Waiter {
  void init() {
    listen('subjects.client', subjects.client.stream, (ravenClient) {
      if (ravenClient == null) {
        deinit();
      } else {
        print('NEW RAVENCLIENT');
        subscribe(ravenClient as RavenElectrumClient);
      }
    });
  }

  void subscribe(RavenElectrumClient ravenClient) {
    print('SUBSCRIBING TO BLOCKS');
    listen(
        'ravenClient.subscribeHeaders',
        ravenClient.subscribeHeaders(),
        (blockHeader) async => await blocks
            .save(Block.fromBlockHeader(blockHeader! as BlockHeader)));
  }
}
