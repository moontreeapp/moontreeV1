import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;

import 'package:raven_back/raven_back.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

import 'constants.dart';

class HandleResult {
  final bool success;
  final String location;
  final LingoKey message;
  HandleResult(this.success, this.location, this.message);
}

class ImportWalletService {
  // TODO: Unsure how to validate this
  ImportFormat? detectImportType(String text) {
    if ((text.startsWith('[') && text.endsWith(']')) ||
        (text.startsWith('{') && text.endsWith('}'))) {
      /// todo must also contain some correct keys
      /// two types of json - ours and outside json formats
      /// TODO: How to verify?
      return ImportFormat.json;
    }

    //TODO: MULTI LANGUAGES OTHER THAN ENGLISH
    if (bip39.validateMnemonic(text)) {
      return ImportFormat.mnemonic;
    }
    try {
      services.wallet.single.privateKeyToWif(text);
      return ImportFormat.privateKey;
    } catch (_) {}
    try {
      //TODO: Tell user that they are in the wrong network mode
      KPWallet.fromWIF(text, res.settings.network);
      return ImportFormat.WIF;
    } catch (_) {}

    /*
    TODO:
    This will require reworks of how we save wallets
    We cannot go from key -> entropy and therefore cannot
    use the raw entropy for creating leader wallets

    try {
      final node = bip32.BIP32.fromBase58(text);
      if (node.privateKey == null) {
        throw Exception('This is a watch only');
      }
      // TODO: We assume that this is an extended private key
      // Could be private/public account/extended key
      return ImportFormat.masterKey;
    } catch (_) {}
    */

    /// these are placeholders, they must be checked
    //var isSeed = text.length == 128;

    /// if we were unable to find a import type, we should be able to check
    /// something to get a good idea if this is known invalid, rather than
    /// returning null. this is a placeholder for that.
    /// TODO: Shouldn't this just be the default?
    if (text.contains('[')) {
      return ImportFormat.invalid;
    }
    return null;
  }

  WalletType typeForImport(String walletType) =>
      walletType == exportedLeaderType
          ? WalletType.leader
          : walletType == exportedSingleType
              ? WalletType.single
              : throw ArgumentError('Wallet must be leader or single');

  Future<List<HandleResult>> handleJson(String text) async {
    //try {
    /// {
    ///   'wallets': {res.wallets.id: values}
    /// }
    /// try decrypt file
    var decodedJSON = json.decode(text) as Map<String, dynamic>;
    if (decodedJSON.containsKey('wallets')) {
      /// create wallets
      var results = <HandleResult>[];
      for (var entry in decodedJSON['wallets']!.entries) {
        var wallet = services.wallet.create(
          walletType: typeForImport(entry.value['type']),
          cipherUpdate: services.cipher.currentCipherUpdate,
          secret: entry.value['secret'],
          alwaysReturn: true,
        );
        results.add(await attemptWalletSave(wallet));
      }
      return results;
    }
    //} catch (e) {}
    // fix later: validate the json before it gets here. then parse it here.
    return [
      HandleResult(false, '', LingoKey.leaderWalletSecretType /* todo fix */)
    ];
  }

  Future<HandleResult> handleMnemonics(String text) async {
    var wallet = services.wallet.create(
      walletType: WalletType.leader,
      cipherUpdate: services.cipher.currentCipherUpdate,
      secret: text,
      alwaysReturn: true,
    );
    return attemptWalletSave(wallet);
  }

  /*
  Future<HandleResult> handleMasterKey(String text) async {
    final node = bip32.BIP32.fromBase58(text);

    return attemptWalletSave(wallet);
  }
  */

  Future<HandleResult> handlePrivateKey(String text) async {
    var wallet = services.wallet.create(
      walletType: WalletType.single,
      cipherUpdate: services.cipher.currentCipherUpdate,
      secret: services.wallet.single.privateKeyToWif(text),
      alwaysReturn: true,
    );
    return attemptWalletSave(wallet);
  }

  Future<HandleResult> handleWIF(String text) async {
    var wallet = services.wallet.create(
      walletType: WalletType.single,
      cipherUpdate: services.cipher.currentCipherUpdate,
      secret: text,
      alwaysReturn: true,
    );
    return attemptWalletSave(wallet);
  }

  Future<HandleResult> handleBip38(String text) async {
    /// check for bip38 encryption
    // 6P valid for rvn?
    if (text.startsWith('6P')) {
      /// prompt for password
      /// decrypt
      /// use key
    }
    return HandleResult(
        false, '', LingoKey.leaderWalletSecretType /* todo fix */);
  }

  //HandleResult handleImport(
  //        ImportFormat importFormat, String text) =>
  //    {
  Future<List<HandleResult>> handleImport(
      ImportFormat importFormat, String text) async {
    var results = await {
      ImportFormat.json: handleJson,
      ImportFormat.mnemonic: handleMnemonics,
      ImportFormat.encryptedBip38: handleBip38,
      ImportFormat.privateKey: handlePrivateKey,
      //ImportFormat.masterKey: handleMasterKey,
      ImportFormat.WIF: handleWIF,
    }[importFormat]!(text);
    if (results is List<HandleResult>) {
      return results;
    }
    return [results as HandleResult];
  }

  String? detectExistingWallet(Wallet wallet) =>
      res.wallets.primaryIndex.getOne(wallet.id)?.id;

  Future<HandleResult> attemptWalletSave(Wallet? wallet) async {
    if (wallet != null) {
      var existingWalletId = detectExistingWallet(wallet);
      if (existingWalletId == null) {
        // since we're importing we assume the user has it backed up already
        wallet.backedUp = true;
        var importedChange = await res.wallets.save(wallet);
        // set it as current before returning
        await res.settings.setCurrentWalletId(importedChange!.data.id);
        return HandleResult(
            true,
            'Wallet ${res.wallets.primaryIndex.getOne(importedChange.data.id)!.name}',
            LingoKey.walletImportedAs);
      }
      return HandleResult(
          false,
          'Wallet ${res.wallets.primaryIndex.getOne(wallet.id)!.name}',
          LingoKey.walletAlreadyExists);
    }
    return HandleResult(false, '', LingoKey.walletUnableToCreate);
  }
}
