import 'package:ordered_set/ordered_set.dart';
import 'package:raven/models/address.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/reservoir/reservoir.dart';

class HistoryReservoir<Record, Model> extends Reservoir {
  HistoryReservoir(source, getPrimaryKey, [mapToModel, mapToRecord])
      : super(source, getPrimaryKey, [mapToModel, mapToRecord]) {
    addIndex('account', (history) => history.accountId);
    addIndex('scripthash', (history) => history.scripthash);
  }

  void removeHistories(String scripthash) {
    return indices['scripthash']!
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
