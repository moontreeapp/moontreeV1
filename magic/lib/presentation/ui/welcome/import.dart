import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wallet_utils/wallet_utils.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/blockchain/mnemonic.dart';
import 'package:magic/domain/storage/secure.dart';
import 'package:magic/domain/wallet/extended_wallet_base.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/other/app_button.dart';
import 'package:magic/services/services.dart';
import 'package:magic/utils/logger.dart';


enum ImportLifecycle {
  entering,
  form,
  validated,
  submitting,
  success,
  failed,
  exiting;

  String get msg {
    switch (this) {
      case ImportLifecycle.submitting:
        return 'Importing please wait';
      case ImportLifecycle.failed:
        return 'Import failed, try again?';
      case ImportLifecycle.success:
        return 'Success!';
      case ImportLifecycle.exiting:
        return ' ';
      default:
        return '';
    }
  }

  String get submitText {
    switch (this) {
      case ImportLifecycle.failed:
        return 'TRY AGAIN';
      case ImportLifecycle.success:
        return 'CLOSE';
      default:
        return 'IMPORT';
    }
  }

  bool get submitEnabled => [
        ImportLifecycle.failed,
        ImportLifecycle.validated,
        ImportLifecycle.success
      ].contains(this);

  bool get animating => [
        ImportLifecycle.entering,
        ImportLifecycle.exiting,
      ].contains(this);
}

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  ImportPageState createState() => ImportPageState();
}

class ImportPageState extends State<ImportPage> {
  ImportLifecycle lifecycle = ImportLifecycle.entering;
  TextEditingController controller = TextEditingController();
  FocusNode textFocus = FocusNode();
  FocusNode submitFocus = FocusNode();
  bool validated = false;

  void toStage(ImportLifecycle stage) {
    if (mounted) {
      if (stage == ImportLifecycle.exiting) {
        cubits.app.animating = true;
        Future.delayed(slideDuration * 1.1, () {
          cubits.welcome.update(active: false, child: const SizedBox.shrink());
          cubits.app.animating = false;
        });
      }
      setState(() => lifecycle = stage);
    }
  }

  bool isValid(String value) =>
      isValidMnemonic(value) || isValidWif(value) || isValidPrivateKey(value);

  void submit() async {
    final value = controller.text.trim();
    if (lifecycle == ImportLifecycle.validated) {
      toStage(ImportLifecycle.submitting);
      if ((isValidMnemonic(value) && await cubits.keys.addMnemonic(value)) ||
          (isValidWif(value) && await cubits.keys.addWif(value)) ||
          (isValidPrivateKey(value) && await cubits.keys.addPrivKey(value))) {
        /// do we need to resetup our subscriptions? yes.
        /// all of them or just this wallet? just do all of them.
        await subscription.setupSubscriptions(cubits.keys.master);

        /// do we need to get all our assets again? yes.
        /// all of them or just this wallet? just do all of them.
        //cubits.wallet.clearAssets();
        await retrievePoolHolding();
        await cubits.wallet.populateAssets();

        if (isValidMnemonic(value)) {
          /// do we need to derive all our addresses? yes.
          /// all of them or just this wallet? we can specify just this wallet.
          deriveInBackground(value);
          // why not use this like we do on startup...?
          //cubits.receive.deriveAll([
          //  Blockchain.ravencoinMain,
          //  Blockchain.evrmoreMain,
          //]);
        }

        /// we always default to the first wallet, so we don't need to do this.
        /// maybe we should default to the last one... it's the one we know they
        /// have backed up if any imported... in that case we should do this.
        //await cubits.receive
        //    .populateAddresses(Blockchain.ravencoinMain);
        //await cubits.receive
        //    .populateAddresses(Blockchain.evrmoreMain);
        toStage(ImportLifecycle.success);
      } else {
        toStage(ImportLifecycle.failed);
      }
    } else if (lifecycle == ImportLifecycle.failed) {
      if (isValid(value)) {
        toStage(ImportLifecycle.validated);
      } else {
        toStage(ImportLifecycle.form);
      }
    } else if (lifecycle == ImportLifecycle.success) {
      toStage(ImportLifecycle.exiting);
    }
  }

  Future<void> retrievePoolHolding() async {
    try {
      final privKey = cubits.keys.master.derivationWallets.last
          .seedWallet(Blockchain.evrmoreMain)
          .subwallet(
            hdIndex: 1,
            exposure: Exposure.external,
          )
          .keyPair
          .toWIF();

      final kpWallet = KPWallet.fromWIF(
        privKey,
        Blockchain.evrmoreMain.network,
      );

      await secureStorage.write(
        key: SecureStorageKey.satoriMagicPool.key(),
        value: jsonEncode({
          "satori_magic_pool": kpWallet.wif,
          "address": kpWallet.address,
        }),
      );
    } catch (e, st) {
      logE('$e,$st');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    textFocus.dispose();
    submitFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lifecycle == ImportLifecycle.entering) {
        toStage(ImportLifecycle.form);
      }
    });
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: <Widget>[
          AnimatedPositioned(
            duration: slideDuration,
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            left: lifecycle.animating ? screen.width : 0,
            right: lifecycle.animating ? -screen.width : 0,
            child: Container(
              alignment: Alignment.center,
              height: screen.height,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  color: AppColors.background),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      top: Platform.isIOS ? 36.0 : 0.0,
                      left: 16.0,
                    ),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white),
                        onPressed: () => toStage(ImportLifecycle.exiting),
                      ),
                    ),
                  ),
                  if (lifecycle.msg == '')
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.foreground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: controller,
                            focusNode: textFocus,
                            maxLines: 4,
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: AppColors.white87),
                            decoration: InputDecoration(
                              hintText: 'Seed Words',
                              hintStyle: const TextStyle(
                                color: AppColors.white38,
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              filled: true,
                              fillColor: Colors.transparent,
                              errorStyle: const TextStyle(
                                height: 0.8,
                                color: AppColors.error,
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              if (lifecycle == ImportLifecycle.form &&
                                  isValid(value.trim())) {
                                toStage(ImportLifecycle.validated);
                              } else if (lifecycle ==
                                      ImportLifecycle.validated &&
                                  !isValid(value.trim())) {
                                toStage(ImportLifecycle.form);
                              }
                            },
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                              submitFocus.requestFocus();
                            },
                            onSubmitted: (value) {
                              FocusScope.of(context).unfocus();
                              submitFocus.requestFocus();
                            },
                          ),
                        ))
                  else
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          lifecycle.msg,
                          textAlign: TextAlign.center,
                        )),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                    child: AppButton(
                      onPressed: submit,
                      label: lifecycle.submitText,
                      isDisabled: !lifecycle.submitEnabled,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
