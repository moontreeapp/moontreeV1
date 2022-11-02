import 'package:ravencoin_back/ravencoin_back.dart';

void printFullState() {
  print('addresses ${pros.addresses.records.length}');
  print('assets ${pros.assets.records.length}');
  print('balances ${pros.balances.records.length}');
  print('blocks ${pros.blocks.records.length}');
  print('ciphers ${pros.ciphers.records.length}');
  print('metadatas ${pros.metadatas.records.length}');
  print('notes ${pros.notes.records.length}');
  print('passwords ${pros.passwords.records.length}');
  print('rates ${pros.rates.records.length}');
  print('securities ${pros.securities.records.length}');
  print('settings ${pros.settings.records.length}');
  print('statuses ${pros.statuses.records.length}');
  print('transactions ${pros.transactions.records.length}');
  print('unspents ${pros.unspents.records.length}');
  print('vins ${pros.vins.records.length}');
  print('vouts ${pros.vouts.records.length}');
  print('wallets ${pros.wallets.records.length}');
  print(
      'subscribe subscriptionHandlesAddress ${services.client.subscribe.subscriptionHandlesAddress}');
  print(
      'subscribe subscriptionHandlesAsset ${services.client.subscribe.subscriptionHandlesAsset}');
  print(
      'services.download.history.calledAllDoneProcess ${services.download.history.calledAllDoneProcess}');
  print(
      'services.download.queue.addresses ${services.download.queue.addresses.length}');
  print(
      'services.download.queue.transactions ${services.download.queue.transactions.length}');
  print(
      'services.download.queue.dangling ${services.download.queue.dangling.length}');
  print('services.download.queue.updated ${services.download.queue.updated}');
  print('services.download.queue.address ${services.download.queue.address}');
  print(
      'services.download.queue.transactionSet ${services.download.queue.transactionSet}');
}
