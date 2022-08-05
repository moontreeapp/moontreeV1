part of 'address.dart';

// primary key

class _ScripthashKey extends Key<Address> {
  @override
  String getKey(Address address) => address.id;
}

extension ByRawScripthashMethodsForAddress on Index<_ScripthashKey, Address> {
  Address? getOne(String addressId) => getByKeyStr(addressId).firstOrNull;
}

// byAddress

class _AddressKey extends Key<Address> {
  @override
  String getKey(Address address) => address.address;
}

extension ByAddressMethodsForAddress on Index<_AddressKey, Address> {
  Address? getOne(String address) => getByKeyStr(address).firstOrNull;
}

// byWallet

class _WalletKey extends Key<Address> {
  @override
  String getKey(Address address) => address.walletId;
}

extension ByWalletMethodsForAddress on Index<_WalletKey, Address> {
  List<Address> getAll(String walletId) => getByKeyStr(walletId);
}

// byWalletExposure

String _walletExposureToKey(String walletId, NodeExposure exposure) =>
    '$walletId:$exposure';

class _WalletExposureKey extends Key<Address> {
  @override
  String getKey(Address address) =>
      _walletExposureToKey(address.walletId, address.exposure);
}

extension ByWalletExposureMethodsForAddress
    on Index<_WalletExposureKey, Address> {
  List<Address> getAll(String walletId, NodeExposure exposure) =>
      getByKeyStr(_walletExposureToKey(walletId, exposure));
}

// byWalletExposureIndex

String _walletExposureHDToKey(
        String walletId, NodeExposure exposure, int hdIndex) =>
    '$walletId:$exposure:$hdIndex';

class _WalletExposureHDKey extends Key<Address> {
  @override
  String getKey(Address address) => _walletExposureHDToKey(
      address.walletId, address.exposure, address.hdIndex);
}

extension ByWalletExposureHDMethodsForAddress
    on Index<_WalletExposureHDKey, Address> {
  Address? getOne(String walletId, NodeExposure exposure, int hdIndex) =>
      getByKeyStr(_walletExposureHDToKey(walletId, exposure, hdIndex))
          .firstOrNull;
}