/* a place to hold all the keys we use to store data on the device. */

enum SecureStorageKey {
  mnemonics,
  wifs,
  authed,
  poolAddress,
  poolActive;

  String key([String? id]) {
    switch (this) {
      case SecureStorageKey.mnemonics:
        return 'mnemonics';
      case SecureStorageKey.wifs:
        return 'wifs';
      case SecureStorageKey.authed:
        return 'authed';
      case SecureStorageKey.poolAddress:
        return 'poolAddress';
      case SecureStorageKey.poolActive:
        return 'poolActive';
    }
  }
}
