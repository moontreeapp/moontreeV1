import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class SettingWaiter extends Waiter {
  void init() {
    listen('settings.batchedChanges', settings.batchedChanges,
        (List<Change<Setting>> batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            added: (added) {
              // will be initialized with settings set of settings
            },
            updated: (updated) {
              var setting = updated.data;
              if ([services.client.chosenDomain, services.client.chosenPort]
                  .contains(setting.name)) {
                subjects.client.sink.add(null);
              }
            },
            removed: (removed) {});
      });
    });
  }
}
