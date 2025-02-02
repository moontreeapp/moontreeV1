import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/mnemonic.dart';
import 'package:magic/domain/storage/secure.dart';
import 'package:magic/domain/wallet/utils.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/services/services.dart';
import 'package:magic/utils/logger.dart';
part 'state.dart';

class KeysCubit extends UpdatableCubit<KeysState> {
  MasterWallet master = MasterWallet();

  KeysCubit() : super(KeysState.empty());
  @override
  String get key => 'keys';
  @override
  void reset() => emit(KeysState.empty());
  @override
  void setState(KeysState state) => emit(state);
  @override
  void hide() {}
  @override
  void activate() => update();
  @override
  void deactivate() => update();
  @override
  void refresh() {
    update(submitting: false);
    update(submitting: true);
  }

  @override
  void update({
    List<Map<String, Map<String, String>>>? xpubs,
    List<Map<String, String>>? xpubsKP,
    List<String>? mnemonics,
    List<String>? wifs,
    bool? submitting,
    bool syncKeys = true,
  }) {
    if (syncKeys) {
      syncMnemonics(mnemonics);
      syncKeypairs(wifs);
      syncXPubs(xpubs, xpubsKP);
    }
    //logD(mnemonics);
    //try {
    //  logD('-----------------------------');
    //  logD(master.derivationWallets.last.mnemonic);
    //  logD(master.derivationWallets.last.roots(Blockchain.evrmoreMain));
    //  logD(master.derivationWallets.last.roots(Blockchain.ravencoinMain));
    //} catch (e) {}
    emit(KeysState(
      xpubs: xpubs ?? state.xpubs,
      xpubsKP: xpubsKP ?? state.xpubsKP,
      mnemonics: mnemonics ?? state.mnemonics,
      wifs: wifs ?? state.wifs,
      submitting: submitting ?? state.submitting,
      prior: state.withoutPrior,
    ));
  }

  Future<bool> addMnemonic(String mnemonic) async {
    if (state.mnemonics.contains(mnemonic)) return true;
    if (!isValidMnemonic(mnemonic)) return false;
    update(mnemonics: [...state.mnemonics, mnemonic]);
    await saveSecrets();
    return true;
  }

  Future<bool> addWif(String wif) async {
    if (state.wifs.contains(wif)) return true;
    if (!isValidWif(wif)) return false;
    update(wifs: [...state.wifs, wif]);
    await saveSecrets();
    return true;
  }

  Future<bool> addPrivKey(String privKey) async {
    if (state.wifs.contains(privKey)) return true;
    if (!isValidPrivateKey(privKey)) return false;
    update(wifs: [...state.wifs, KeypairWallet.privateKeyToWif(privKey)]);
    await saveSecrets();
    return true;
  }

  Future<bool> removeMnemonic(String mnemonic) async {
    if (!state.mnemonics.contains(mnemonic)) return true;
    update(mnemonics: state.mnemonics.where((m) => m != mnemonic).toList());
    await saveSecrets();
    return true;
  }

  Future<bool> removeWif(String wif) async {
    if (!state.wifs.contains(wif)) return true;
    update(wifs: state.wifs.where((w) => w != wif).toList());
    await saveSecrets();
    return true;
  }

  // blockchain layer
  Future<void> loadXPubs() async {
    final List<dynamic> rawXpubs =
        jsonDecode(await (storage.read(key: StorageKey.xpubs.key())) ?? '[]');

    final List<Map<String, Map<String, String>>> xpubs = rawXpubs.map((entry) {
      // Ensure that the entry is cast to Map<String, dynamic> first
      final Map<String, dynamic> castEntry = Map<String, dynamic>.from(entry);

      // Then transform it to the desired structure: Map<String, Map<String, String>>
      return castEntry.map((key, value) {
        // Ensure that the value is a Map<String, String>
        return MapEntry(key, Map<String, String>.from(value));
      });
    }).toList();
    final List<dynamic> rawXpubsKP =
        jsonDecode(await (storage.read(key: StorageKey.xpubsKP.key())) ?? '[]');
    final List<Map<String, String>> xpubsKP = rawXpubsKP
        .map((entry) => Map<String, String>.from(entry)
            .map((key, value) => MapEntry(key, value)))
        .toList();
    logE('$rawXpubsKP, $xpubsKP');
    if (xpubs.isNotEmpty && xpubs != [{}]) {
      update(submitting: true);
      update(
        xpubs: xpubs,
        xpubsKP: xpubsKP,
        submitting: false,
      );
    } else {
      await loadSecrets(onExisting: () async {
        await saveXPubs();
        await saveXPubsKP();
      });
    }
  }

  Future<void> clearAll() async {
    master = MasterWallet();
    update(mnemonics: [], wifs: [], xpubs: []);
  }

  Future<void> loadSecrets({Future<void> Function()? onExisting}) async {
    update(submitting: true);
    update(
      mnemonics: jsonDecode((await secureStorage.read(
                  key: SecureStorageKey.mnemonics.key())) ??
              '[]')
          .cast<String>(),
      wifs: jsonDecode(
              (await secureStorage.read(key: SecureStorageKey.wifs.key())) ??
                  '[]')
          .cast<String>(),
      submitting: false,
    );
    await build(onExisting: onExisting);
  }

  Future<void> build({Future<void> Function()? onExisting}) async {
    if (state.mnemonics.isEmpty) {
      update(submitting: true);
      update(
        mnemonics: [makeMnemonic()],
        submitting: false,
      );
      saveSecrets();
    } else {
      // for zedge case - we should never have mnemonics on disk without xpubs
      // but if for some wild reason we do, we should save the xpubs now.
      if (onExisting != null) {
        await onExisting();
      }
    }
  }

  /// we don't really need to sync with xpubs because we always add them all at
  /// once (on startup). If we import a wallet, we switch over to using
  /// privkeys, and then rewrite all the xpubs to disk again.
  Future<void> syncXPubs(List<Map<String, Map<String, String>>>? xpubs,
      List<Map<String, String>>? xpubsKP) async {
    if (xpubs != null) {
      master.derivationWallets.addAll(xpubs.map((blockchainExposureXpub) =>
          DerivationWallet.fromRoots(blockchainExposureXpub)));
    }
    if (xpubsKP != null) {
      master.keypairWallets.addAll(xpubsKP.map((blockchainExposureXpub) =>
          KeypairWallet.fromRoots(blockchainExposureXpub)));
    }
  }

  Future<void> syncMnemonics(List<String>? mnemonics) async {
    if (mnemonics != null) {
      final existingMnemonics =
          master.derivationWallets.map((e) => e.mnemonic).toSet();
      final addable = mnemonics.toSet().difference(existingMnemonics);
      final removable = existingMnemonics.difference(mnemonics.toSet());
      master.derivationWallets.addAll(
          addable.map((mnemonic) => DerivationWallet(mnemonic: mnemonic)));
      master.derivationWallets.removeWhere(
          (derivationWallet) => removable.contains(derivationWallet.mnemonic));
    }
    //for (final blockchain in Blockchain.values) {
    //  for (final derivationWallet in master.derivationWallets) {
    //    derivationWallet.pubkey(blockchain);
    //  }
    //}
  }

  Future<void> syncKeypairs(List<String>? wifs) async {
    if (wifs != null) {
      final existingWifs = master.keypairWallets.map((e) => e.wif).toSet();
      final addable = wifs.toSet().difference(existingWifs);
      final removable = existingWifs.difference(wifs.toSet());
      master.keypairWallets
          .addAll(addable.map((wif) => KeypairWallet(wif: wif)));
      master.keypairWallets.removeWhere(
          (keypairWallet) => removable.contains(keypairWallet.wif));
    }
  }

  Future<void> saveSecrets() async {
    secureStorage.write(
        key: SecureStorageKey.mnemonics.key(),
        value: jsonEncode(state.mnemonics));
    secureStorage.write(
        key: SecureStorageKey.wifs.key(), value: jsonEncode(state.wifs));
    // every time we save secrets we save xpubs because the secrets are our
    // source of truth for the xpubs:
    await saveXPubs();
    await saveXPubsKP();
  }

  void ensureSeedWalletsExist() {
    for (final blockcahin in Blockchain.mainnets) {
      for (final derivationWallet in master.derivationWallets) {
        derivationWallet.rootsMap(blockcahin);
      }
    }
  }

  void ensureKPWalletsExist() {
    for (final blockcahin in Blockchain.mainnets) {
      for (final keypairWallet in master.keypairWallets) {
        keypairWallet.wallet(blockcahin);
      }
    }
  }

  Future<void> saveXPubs() async {
    ensureSeedWalletsExist();
    final write = jsonEncode(master.derivationWallets
        .map((wallet) => wallet.asRootXPubMap)
        .toList());
    storage.writeKey(
      key: StorageKey.xpubs,
      value: write,
    );
  }

  Future<void> saveXPubsKP() async {
    ensureKPWalletsExist();
    final write = jsonEncode(
        master.keypairWallets.map((wallet) => wallet.asRootXPubMap).toList());
    storage.writeKey(
      key: StorageKey.xpubsKP,
      value: write,
    );
  }
}
