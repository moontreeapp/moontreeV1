part of 'history.dart';

// primary key

class _TxHashKey extends Key<History> {
  @override
  String getKey(History history) => history.hash;
}

extension ByIdMethodsForHistory on Index<_TxHashKey, History> {
  History? getOne(String hash) => getByKeyStr(hash).firstOrNull;
}

// byAccount

class _AccountKey extends Key<History> {
  @override
  String getKey(History history) => history.address!.wallet!.accountId;
}

extension ByAccountMethodsForHistory on Index<_AccountKey, History> {
  List<History> getAll(String accountId) => getByKeyStr(accountId);

  Iterable<History> transactions(String accountId, {Security security = RVN}) =>
      HistoryReservoir.whereTransaction(
          given: getAll(accountId), security: security);

  Iterable<History> unspents(String accountId, {Security security = RVN}) =>
      HistoryReservoir.whereUnspent(
          given: getAll(accountId), security: security);

  Iterable<History> unconfirmed(String accountId, {Security security = RVN}) =>
      HistoryReservoir.whereUnconfirmed(
          given: getAll(accountId), security: security);
}

// byWallet

class _WalletKey extends Key<History> {
  @override
  String getKey(History history) => history.address!.walletId;
}

extension ByWalletMethodsForHistory on Index<_WalletKey, History> {
  List<History> getAll(String walletId) => getByKeyStr(walletId);

  Iterable<History> transactions(String walletId, {Security security = RVN}) =>
      HistoryReservoir.whereTransaction(
          given: getAll(walletId), security: security);

  Iterable<History> unspents(String walletId, {Security security = RVN}) =>
      HistoryReservoir.whereUnspent(
          given: getAll(walletId), security: security);

  Iterable<History> unconfirmed(String walletId, {Security security = RVN}) =>
      HistoryReservoir.whereUnconfirmed(
          given: getAll(walletId), security: security);
}

// byScripthash

class _ScripthashKey extends Key<History> {
  @override
  String getKey(History history) => history.scripthash;
}

extension ByScripthashMethodsForHistory on Index<_ScripthashKey, History> {
  List<History> getAll(String scripthash) => getByKeyStr(scripthash);
}

// bySecurity

class _SecurityKey extends Key<History> {
  @override
  String getKey(History history) => history.security.toKey();
}

extension BySecurityMethodsForHistory on Index<_SecurityKey, History> {
  List<History> getAll(Security security) => getByKeyStr(security.toKey());

  Iterable<History> unspents({Security security = RVN}) =>
      HistoryReservoir.whereUnspent(
          given: getAll(security), security: security);

  BalanceRaw balance({Security security = RVN}) {
    var zero = BalanceRaw(confirmed: 0, unconfirmed: 0);
    return unspents(security: security).fold(
        zero,
        (sum, history) =>
            sum +
            BalanceRaw(
                confirmed: (history.confirmed ? history.value : 0),
                unconfirmed: (!history.confirmed ? history.value : 0)));
  }
}

// byConfirmed

class _ConfirmedKey extends Key<History> {
  @override
  String getKey(History history) => history.confirmed.toString();
}

extension ByConfrimedMethodsForHistory on Index<_ConfirmedKey, History> {
  List<History> getAll(bool confirmed) => getByKeyStr(confirmed.toString());
}
