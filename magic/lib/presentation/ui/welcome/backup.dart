import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/ui/welcome/privacy.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/other/app_button.dart';
import 'package:magic/services/services.dart';

enum BackupLifeCycle {
  entering,
  hidden,
  shown,
  exiting;

  String get msg {
    switch (this) {
      case BackupLifeCycle.entering:
      case BackupLifeCycle.hidden:
        return 'Confirm\nView sensitive backup words?';
      case BackupLifeCycle.exiting:
        return ' ';
      default:
        return '';
    }
  }

  String get submitText {
    switch (this) {
      case BackupLifeCycle.shown:
        return 'DONE';
      default:
        return 'VIEW';
    }
  }

  bool get animating => [
        BackupLifeCycle.entering,
        BackupLifeCycle.exiting,
      ].contains(this);
}

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  BackupPageState createState() => BackupPageState();
}

class BackupPageState extends State<BackupPage> {
  BackupLifeCycle lifecycle = BackupLifeCycle.entering;

  void toStage(BackupLifeCycle stage) {
    if (mounted) {
      if (stage == BackupLifeCycle.exiting) {
        cubits.app.animating = true;
        Future.delayed(slideDuration * 1.1, () {
          cubits.welcome.update(active: false, child: const SizedBox.shrink());
          cubits.app.animating = false;
        });
      }
      setState(() => lifecycle = stage);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lifecycle == BackupLifeCycle.entering) {
        toStage(BackupLifeCycle.hidden);
      }
    });
    return Privacy(
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
                          onPressed: () => toStage(BackupLifeCycle.exiting),
                        ),
                      )),
                  if (lifecycle.msg != '')
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Confirm\n',
                                  style: TextStyle(
                                    color: AppColors.white87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Nunito',
                                    letterSpacing: 0.15,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'View ',
                                  style: TextStyle(
                                    color: AppColors.white87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Nunito',
                                    letterSpacing: 0.5,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'sensitive',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Nunito',
                                    letterSpacing: 0.5,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: ' backup words?',
                                  style: TextStyle(
                                    color: AppColors.white87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Nunito',
                                    letterSpacing: 0.5,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: AppButton(
                                  onPressed: () =>
                                      toStage(BackupLifeCycle.exiting),
                                  label: 'NO',
                                  buttonColor: AppColors.foreground,
                                  textColor: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 56,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AppButton(
                                  onPressed: () =>
                                      toStage(BackupLifeCycle.shown),
                                  label: 'YES',
                                  buttonColor: AppColors.button,
                                  textColor: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 56,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: screen.height - 60 - 60 - 32 - 100,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                cubits.keys.master.derivationWallets.length +
                                    cubits.keys.master.keypairWallets.length,
                            itemBuilder: (context, int index) {
                              final isDerivationWallet = index <
                                  cubits.keys.master.derivationWallets.length;
                              final walletIndex = isDerivationWallet
                                  ? index
                                  : index -
                                      cubits
                                          .keys.master.derivationWallets.length;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 32),
                                  GestureDetector(
                                      onLongPress: () {
                                        if (isDerivationWallet) {
                                          Clipboard.setData(ClipboardData(
                                              text: cubits
                                                  .keys
                                                  .master
                                                  .derivationWallets[index]
                                                  .parentPrivateKey));
                                          cubits.toast.flash(
                                              msg: const ToastMessage(
                                                  duration:
                                                      Duration(seconds: 3),
                                                  title: 'Master Private Key',
                                                  text: 'copied to clipboard'));
                                        } else {
                                          Clipboard.setData(ClipboardData(
                                              text: cubits
                                                  .keys
                                                  .master
                                                  .keypairWallets[walletIndex]
                                                  .wif));
                                          cubits.toast.flash(
                                              msg: const ToastMessage(
                                                  duration:
                                                      Duration(seconds: 3),
                                                  title: 'Private Key',
                                                  text: 'copied to clipboard'));
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Text(
                                          'Wallet ${isDerivationWallet ? index + 1 : index + cubits.keys.master.derivationWallets.length}',
                                          style: const TextStyle(
                                            color: AppColors.white87,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Nunito',
                                            letterSpacing: 0.5,
                                            height: 1.5,
                                          ),
                                        ),
                                      )),
                                  isDerivationWallet
                                      ? GestureDetector(
                                          onLongPress: () {
                                            Clipboard.setData(ClipboardData(
                                                text: cubits
                                                    .keys
                                                    .master
                                                    .derivationWallets[index]
                                                    .words
                                                    .join(' ')));
                                            cubits.toast.flash(
                                                msg: const ToastMessage(
                                                    duration:
                                                        Duration(seconds: 3),
                                                    title: 'Seed Words',
                                                    text:
                                                        'copied to clipboard'));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                childAspectRatio: 3,
                                                crossAxisSpacing: 16,
                                                mainAxisSpacing: 8,
                                              ),
                                              itemCount: cubits
                                                  .keys
                                                  .master
                                                  .derivationWallets[index]
                                                  .words
                                                  .length,
                                              itemBuilder:
                                                  (context, wordIndex) {
                                                final word = cubits
                                                    .keys
                                                    .master
                                                    .derivationWallets[index]
                                                    .words[wordIndex];
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.foreground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32),
                                                  ),
                                                  child:
                                                      Center(child: Text(word)),
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: GestureDetector(
                                            onLongPress: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: cubits
                                                      .keys
                                                      .master
                                                      .keypairWallets[
                                                          walletIndex]
                                                      .wif));
                                              cubits.toast.flash(
                                                  msg: const ToastMessage(
                                                      duration:
                                                          Duration(seconds: 3),
                                                      title: 'Private Key',
                                                      text:
                                                          'copied to clipboard'));
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  left: 8,
                                                  right: 8,
                                                  top: 4,
                                                  bottom: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.foreground,
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              child: Text(
                                                  'wif: ${cubits.keys.master.keypairWallets[walletIndex].wif}'),
                                            ),
                                          ),
                                        ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 64,
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
