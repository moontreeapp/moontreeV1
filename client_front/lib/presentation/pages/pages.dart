// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'package:client_front/presentation/pages/splash.dart';
import 'package:client_front/presentation/pages/login/login.dart';
import 'package:client_front/presentation/pages/wallet/wallet.dart';
import 'package:client_front/presentation/pages/backup/backup.dart';
import 'package:client_front/presentation/pages/restore/restore.dart';
import 'package:client_front/presentation/pages/settings/settings.dart';
import 'package:client_front/presentation/pages/support/support.dart';

final _staticRoutes = <String, Widget Function(BuildContext)>{
  '/': (BuildContext context) => const PreLogin(),
  '/splash': (BuildContext context) => const Splash(),
  '/login/create': (BuildContext context) => const LoginCreate(),
  '/login/create/native': (BuildContext context) => const LoginCreateNative(),
  '/login/create/resume': (BuildContext context) => const CreateResume(),
  '/login/create/password': (BuildContext context) =>
      const LoginCreatePassword(),
  '/login/native': (BuildContext context) => const LoginNative(),
  '/login/password': (BuildContext context) => const LoginPassword(),
  '/wallet/receive': (BuildContext context) => const Receive(),
  '/wallet/holdings': (BuildContext context) => const WalletHoldings(),
  '/wallet/holding': (BuildContext context) => const WalletHolding(),
  '/wallet/holding/transaction': (BuildContext context) =>
      const TransactionPage(),
  '/wallet/send': (BuildContext context) => const SimpleSend(),
  '/wallet/send/checkout': (BuildContext context) =>
      SimpleSendCheckout(transactionType: TransactionType.spend),
  '/backup/intro': (BuildContext context) => const BackupIntro(),
  '/backup/keypair': (BuildContext context) => const ShowKeypair(),
  '/backup/seed': (BuildContext context) => const BackupSeed(),
  '/backup/verify': (BuildContext context) => const VerifySeed(),
  '/restore/import': (BuildContext context) => const ImportPage(),
  //'/restore/export': (BuildContext context) => const Export(),
  '/support/about': (BuildContext context) => const About(),
  '/support/support': (BuildContext context) => const SupportPage(),
  '/mode/developer': (BuildContext context) => const DeveloperMode(),
  '/mode/advanced': (BuildContext context) => const AdvancedDeveloperMode(),
  '/setting/database': (BuildContext context) => const DatabaseSettings(),
  '/setting/mining': (BuildContext context) => const MiningSetting(),
  '/setting/security': (BuildContext context) => const SecuritySettings(),
  '/security/security': (BuildContext context) =>
      const SecuritySettings(), // update this
  '/network/blockchain': (BuildContext context) => const BlockchainSettings(),
  '/send/checkout': (BuildContext context) => SimpleSendCheckout(
        transactionType: TransactionType.spend,
      ),
};

Map<String, Widget Function(BuildContext)> get routes => _staticRoutes;
