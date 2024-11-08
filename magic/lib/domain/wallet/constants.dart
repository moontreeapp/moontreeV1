const String exportedLeaderType = 'Leader';
const String exportedSingleType = 'Single';

enum ImportFormat {
  json,
  jsonWif, // unused
  jsonMt, // unused
  mnemonic,
  encryptedBip38, //unused
  wif,
  seed, // unused
  privateKey,
  masterKey,
  invalid,
}

enum WalletType {
  leader,
  single,
  none,
}
