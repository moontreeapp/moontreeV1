import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/send/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/pane/send/confirm_placeholder.dart';
import 'package:magic/presentation/ui/pane/send/scanner.dart';
import 'package:magic/presentation/ui/pane/send/confirm.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';
import 'package:magic/presentation/widgets/other/app_button.dart';
import 'package:magic/services/services.dart';
import 'package:magic/utils/log.dart';

class SendPage extends StatelessWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SendCubit, SendState>(
      buildWhen: (SendState prior, SendState current) =>
          prior.sendRequest != current.sendRequest ||
          prior.unsignedTransaction != current.unsignedTransaction ||
          prior.estimate != current.estimate,
      builder: (BuildContext context, SendState state) {
        if (state.isSubmitting) {
          return const ConfirmContentPlaceholder();
        }
        if (state.unsignedTransaction != null && state.estimate != null) {
          //return LoginNative(
          //  onFailure: cubits.appbar.state.onLead,
          //  child: const ConfirmContent(),
          //);
          return const ConfirmContent();
        }
        return const SendContent();
        //if (state.sendRequest == null) {
        //  return const SendContent();
        //}
        //if (state.unsignedTransaction == null) {
        //  return const ConfirmContent();
        //  return Container(
        //      height: screen.pane.midHeight,
        //      alignment: Alignment.center,
        //      child: const Text('please wait...'));
        //}
        //return const ConfirmContent();
      });
}

class SendContent extends StatefulWidget {
  const SendContent({super.key});

  @override
  SendContentState createState() => SendContentState();
}

class SendContentState extends State<SendContent> {
  final TextEditingController addressText =
      TextEditingController(text: cubits.send.state.address);
  final TextEditingController amountText =
      TextEditingController(text: cubits.send.state.amount);
  bool amountDollars = false;
  bool automaticConversion = false;
  bool userChanged = false;

  @override
  void dispose() {
    addressText.dispose();
    amountText.dispose();
    super.dispose();
  }

// ignore: slash_for_doc_comments
  /** validation
   * ETJ8zPcJiBYBxCdiiHt37xCfXRKVRuBsp7
      String _asDoubleString(double x) {
      if (x.toString().endsWith('.0')) {
      return x.toString().replaceAll('.0', '');
      }
      return x.toString();
      }

      bool _validateDivisibility([String? value]) =>
      (components.cubits.simpleSendForm.state.metadataView?.divisibility ??
      8) >=
      ((value ?? sendAmount.text).contains('.')
      ? (value ?? sendAmount.text).split('.').last.length
      : 0);
      bool _holdingValidation(SimpleSendFormState state) {
      final quantity = sendAmount.textWithoutCommas;
      if (_asDouble(quantity) == 0.0) {
      return false;
      }
      if (holdingBalance.security.isCoin) {
      // we have enough coin for the send and minimum fee estimate
      // actaully don't do this because we can send all.
      if (holdingBalance.amount == double.parse(quantity)) {
      return true;
      }
      // if not sending all:
      return holdingBalance.amount > double.parse(quantity) + 0.0021;
      } else {
      final BalanceView? holdingView =
      components.cubits.holdingsView.holdingsViewFor(Current.coin.symbol);
      // we have enough asset for the send and enough coin for minimum fee
      return holdingBalance.amount >= double.parse(quantity) &&
      holdingView!.satsConfirmed + holdingView.satsUnconfirmed > 210000;
      }
      //return (state.security.balance?.amount ?? 0) >=
      //    double.parse(sendAmount.textWithoutCommas);
      }
      final bool vAddress = sendAddress.text != '' && _validateAddress();
      bool _validateAddress([String? address]) {
      address ??= sendAddress.text;
      return address == '' ||
      (pros.settings.chain == Chain.ravencoin
      ? pros.settings.net == Net.main
      ? address.isAddressRVN
      : address.isAddressRVNt
      : pros.settings.net == Net.main
      ? address.isAddressEVR
      : address.isAddressEVRt);
      }

   */

  bool validateVisibleForm() =>
      cubits.send.validateAddress(addressText.text) &&
      cubits.send.validateAmount(amountText.text);

  String formatWithCommas(String value) {
    if (value.isEmpty) return value;
    final parts = value.split('.');
    parts[0] = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return parts.join('.');
  }

  @override
  Widget build(BuildContext context) => Container(
      height: screen.pane.midHeight,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        BlocBuilder<SendCubit, SendState>(
            buildWhen: (SendState prior, SendState current) =>
                prior.scanActive != current.scanActive ||
                prior.fromQR != current.fromQR,
            builder: (BuildContext context, SendState state) {
              if (state.scanActive) {
                return FadeIn(
                  duration: fadeDuration,
                  child: Container(
                    padding: const EdgeInsets.only(top: 8),
                    constraints: BoxConstraints(maxHeight: screen.width - 32),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28.0),
                      child: const QRViewable(),
                    ),
                  ),
                );
              }
              if (state.fromQR == true) {
                addressText.text = cubits.send.state.address;
                amountText.text = cubits.send.state.amount;
                cubits.send.update(fromQR: false);
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  GestureDetector(
                    onDoubleTap: () async {
                      String potentialAddress =
                          (await Clipboard.getData('text/plain'))?.text ?? '';
                      if (cubits.send.validateAddress(potentialAddress)) {
                        addressText.text = potentialAddress;
                        cubits.send.update(address: potentialAddress);
                      }
                    },
                    child: CustomTextField(
                      textInputAction: TextInputAction.next,
                      controller: addressText,
                      labelText: 'To',
                      suffixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                              onTap: () {
                                cubits.send.update(
                                    scanActive: !cubits.send.state.scanActive);
                              },
                              child: const Icon(Icons.qr_code_scanner,
                                  color: AppColors.white60))),
                      errorText: addressText.text.trim() == '' ||
                              cubits.send.validateAddress(addressText.text)
                          ? null
                          : cubits.send
                              .invalidAddressMessages(addressText.text)
                              .firstOrNull,
                      onChanged: (value) => setState(() {
                        if (cubits.send.validateAddress(addressText.text)) {
                          cubits.send.update(address: value);
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onDoubleTap: () async {
                      if (amountDollars) {
                        String potentialAmount =
                            (await Clipboard.getData('text/plain'))?.text ?? '';
                        try {
                          final fiatAmount = Fiat(double.tryParse(
                                  potentialAmount.trim().replaceAll(',', '')) ??
                              0);
                          setState(() {
                            amountText.text = fiatAmount.toString();
                          });
                        } catch (e) {
                          see(e);
                        }
                      } else {
                        amountText.text =
                            cubits.holding.state.holding.coin.entire();
                        setState(() {
                          cubits.send.update(
                              amount:
                                  cubits.holding.state.holding.coin.entire());
                        });
                      }
                    },
                    child: CustomTextField(
                      textInputAction: TextInputAction.done,
                      controller: amountText,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: false, decimal: true),
                      labelText: amountDollars ? 'Amount in USD' : 'Amount',
                      suffixIcon: ['0', '-'].contains(Coin.fromString(
                                  amountText.text.replaceAll(',', ''))
                              .toFiat(cubits.holding.state.holding.rate)
                              .toString())
                          ? null
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() => automaticConversion = true);
                                    setState(() {
                                      if (amountDollars) {
                                        if (userChanged) {
                                          final convertedAmount = Fiat(
                                                  double.tryParse(amountText
                                                          .text
                                                          .trim()
                                                          .replaceAll(
                                                              ',', '')) ??
                                                      0)
                                              .toCoin(cubits
                                                  .holding.state.holding.rate)
                                              .toString();
                                          amountText.text =
                                              formatWithCommas(convertedAmount);
                                        } else {
                                          amountText.text = formatWithCommas(
                                              cubits.send.state.originalAmount);
                                        }
                                      } else {
                                        // Store the original token amount before conversion
                                        final originalAmount =
                                            amountText.text.replaceAll(',', '');
                                        final usdAmount =
                                            Coin.fromString(originalAmount)
                                                .toFiat(cubits
                                                    .holding.state.holding.rate)
                                                .toString();
                                        amountText.text = usdAmount;
                                        // Store the original amount for later use
                                        cubits.send.update(
                                            originalAmount: originalAmount);
                                      }
                                      amountDollars = !amountDollars;
                                    });
                                    setState(() {
                                      automaticConversion = false;
                                      userChanged = false;
                                    });
                                  },
                                  child: Icon(
                                      amountDollars
                                          ? Icons.attach_money_rounded
                                          : Icons.toll_rounded,
                                      color: AppColors.white60))),
                      errorText: amountDollars
                          ? userChanged
                              ? cubits.send
                                  .invalidAmountMessages(Fiat(double.tryParse(
                                              amountText.text
                                                  .trim()
                                                  .replaceAll(',', '')) ??
                                          0)
                                      .toCoin(cubits.holding.state.holding.rate)
                                      .toString())
                                  .firstOrNull
                              : cubits.send
                                  .invalidAmountMessages(
                                      cubits.send.state.amount)
                                  .firstOrNull
                          : amountText.text.trim() == '' ||
                                  cubits.send.validateAmount(amountText.text)
                              ? null
                              : cubits.send
                                  .invalidAmountMessages(amountText.text)
                                  .first,
                      onChanged: (value) {
                        see(value);
                        if (automaticConversion) {
                          return;
                        }
                        userChanged = true;

                        // Remove existing commas before processing
                        String cleanValue = value.replaceAll(',', '');

                        if (amountDollars) {
                          // Format USD input with commas
                          final formattedValue = formatWithCommas(cleanValue);
                          if (formattedValue != value) {
                            amountText.value = amountText.value.copyWith(
                              text: formattedValue,
                              selection: TextSelection.collapsed(
                                  offset: formattedValue.length),
                            );
                          }

                          // Convert USD to coin amount for validation and cubit update
                          final coinAmount =
                              Fiat(double.tryParse(cleanValue) ?? 0)
                                  .toCoin(cubits.holding.state.holding.rate)
                                  .toString();

                          setState(() {
                            if (cubits.send.validateAmount(coinAmount)) {
                              cubits.send.update(amount: coinAmount);
                            }
                          });
                        } else {
                          // Format coin amount input with commas
                          final formattedValue = formatWithCommas(cleanValue);
                          if (formattedValue != value) {
                            amountText.value = amountText.value.copyWith(
                              text: formattedValue,
                              selection: TextSelection.collapsed(
                                  offset: formattedValue.length),
                            );
                          }

                          setState(() {
                            if (cubits.send.validateAmount(cleanValue)) {
                              cubits.send.update(amount: cleanValue);
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              );
            }),
        BlocBuilder<SendCubit, SendState>(
          buildWhen: (SendState prior, SendState current) =>
              prior.scanActive != current.scanActive,
          builder: (BuildContext context, SendState state) {
            if (state.scanActive) {
              return TextButton(
                onPressed: () => cubits.send.update(scanActive: false),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Container(
                  height: 64,
                  alignment: Alignment.center,
                  child: Text(
                    'CLOSE SCANNER',
                    style: AppText.button1.copyWith(
                      fontSize: 16,
                      color: AppColors
                          .button, // Use the same color as the original button background
                    ),
                  ),
                ),
              );
            }
            return AppButton(
              onPressed: () =>
                  cubits.send.validateForm() && validateVisibleForm()
                      ? cubits.send.send()
                      : cubits.toast.flash(
                          msg: const ToastMessage(
                            title: 'Unable to Continue:',
                            text: 'Invalid form',
                          ),
                        ),
              label: 'PREVIEW',
            );
          },
        ),
      ]));
}

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? labelText;
  final String? errorText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.labelText,
    this.errorText,
    this.suffixIcon,
    this.textInputAction,
    this.onChanged,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;
  bool _isFilled = false;

  @override
  void initState() {
    super.initState();
    _isFocused = widget.focusNode?.hasFocus ?? false;
    _isFilled = ![null, ''].contains(widget.controller?.text.trim());
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
    widget.focusNode?.addListener(_handleFocusChange);
    widget.controller?.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? _focusNode.hasFocus;
    });
  }

  void _handleTextChange() {
    setState(() {
      _isFilled = (widget.controller ?? _controller).text.trim() != '';
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    widget.focusNode?.removeListener(_handleFocusChange);
    widget.controller?.removeListener(_handleTextChange);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 64,
          decoration: ShapeDecoration(
            color: AppColors.frontItem,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28 * 100),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: 14, left: 24, right: widget.suffixIcon == null ? 24 : 56),
          child: TextField(
            controller: widget.controller ?? _controller,
            focusNode: widget.focusNode ?? _focusNode,
            autocorrect: false,
            textInputAction: widget.textInputAction,
            keyboardType: widget.keyboardType,
            cursorColor: AppColors.white67,
            style: const TextStyle(color: AppColors.white87),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
              contentPadding: EdgeInsets.zero,
              errorText: widget.errorText,
              errorStyle: const TextStyle(
                height: 0.8,
                color: AppColors.error,
              ),
              //suffixIcon: widget.suffixIcon,
            ),
            onChanged: widget.onChanged,
            inputFormatters: widget.labelText == 'To'
                ? []
                : [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      // Allow only digits, comma, and dot
                      final newString =
                          newValue.text.replaceAll(RegExp(r'[^\d,.]'), '');
                      // Ensure only one dot is present
                      final dotCount = newString.split('.').length - 1;
                      if (dotCount > 1) {
                        return oldValue;
                      }
                      return TextEditingValue(
                        text: newString,
                        selection:
                            TextSelection.collapsed(offset: newString.length),
                      );
                    }),
                  ],
          ),
        ),
        if (widget.suffixIcon != null)
          Positioned(top: 18, right: 20, child: widget.suffixIcon!),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          left: 24.0,
          top: _isFocused || _isFilled ? 6.0 : 18.0,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppText.subtitle1.copyWith(
              fontSize: _isFocused || _isFilled ? 12.0 : 16.0,
            ),
            child: Text(widget.labelText ?? ''),
          ),
        ),
      ],
    );
  }
}
