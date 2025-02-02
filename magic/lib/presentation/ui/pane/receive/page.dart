import 'dart:io';
import 'package:magic/presentation/widgets/other/app_button.dart';
import 'package:magic/services/deep_link.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/presentation/ui/pane/wallet/page.dart';
import 'package:magic/utils/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/services/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenshotController screenshotController = ScreenshotController();
    return Container(
        height: screen.pane.midHeight,
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        if (cubits.receive.state.address.isEmpty) {
                          cubits.receive.populateReceiveAddress(
                              cubits.holding.state.holding.blockchain);
                        }
                        Clipboard.setData(
                            ClipboardData(text: cubits.receive.state.address));
                        cubits.toast.flash(
                            msg: const ToastMessage(
                                duration: Duration(seconds: 2),
                                title: 'copied',
                                text: 'to clipboard'));
                      },
                      child: Screenshot(
                        controller: screenshotController,
                        child: SizedBox(
                            height: screen.width - 32 * 4,
                            width: screen.width - 32 * 4,
                            child: QrImageView(
                                backgroundColor: AppColors.front,
                                data: cubits.receive.state.address,
                                eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: AppColors.white),
                                dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: AppColors.white),
                                //foregroundColor: AppColors.primary,
                                //embeddedImage: Image.asset(
                                //        'assets/logo/moontree_logo.png')
                                //    .image,
                                size: screen.width - 32 * 2)),
                      )),
                  SizedBox(height: screen.hspace),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// todo: this needs to be the blockchain of the address not the holding
                      /// of course it should always be the same so validate it
                      CurrencyIdenticon(
                        holding: cubits.holding.state.holding,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                          child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SelectableText.rich(
                          TextSpan(
                            text: '',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: AppColors.white.withOpacity(.44)),
                            children: <TextSpan>[
                              TextSpan(
                                text: cubits.receive.state.address
                                    .substring(0, 6),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: cubits.receive.state.address.substring(
                                    6, cubits.receive.state.address.length - 6),
                              ),
                              TextSpan(
                                text: cubits.receive.state.address.substring(
                                    cubits.receive.state.address.length - 6),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'COPY',
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: cubits.receive.state.address));
                        cubits.toast.flash(
                          msg: const ToastMessage(
                            duration: Duration(seconds: 2),
                            title: 'copied',
                            text: 'to clipboard',
                          ),
                        );
                      },
                    ),
                  ),
                  if (!Platform.isIOS) const SizedBox(width: 16),
                  if (!Platform.isIOS)
                    Expanded(
                      child: AppButton(
                        label: 'SHARE',
                        onPressed: () {
                          screenshotController.capture().then((image) {
                            logD('image: ${image?.length}');
                            if (image != null) {
                              shareQRCode(image);
                            }
                          });
                        },
                      ),
                    ),
                ],
              )
            ]));
  }

  Future<void> shareQRCode(Uint8List image) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/qr.png');
    await file.writeAsBytes(image);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          name: 'qr.png',
        ),
      ],
      text: DeepLinkService.generateReceiveDeepLink(
        address: cubits.receive.state.address,
      ),
    );
  }
}
