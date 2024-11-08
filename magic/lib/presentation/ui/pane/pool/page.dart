import 'package:magic/presentation/ui/pane/pool/pool_placeholder.dart';
import 'package:magic/presentation/widgets/other/app_button.dart';
import 'package:magic/presentation/widgets/other/app_dialog.dart';
import 'package:magic/presentation/ui/pane/send/page.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/services/services.dart';
import 'package:magic/cubits/cubits.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic/utils/log.dart';

class PoolPage extends StatelessWidget {
  const PoolPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PoolCubit, PoolState>(
        builder: (BuildContext context, PoolState state) {
          if (state.isSubmitting) {
            return const PoolContentPlaceholder();
          } else {
            switch (state.poolStatus) {
              case PoolStatus.joined:
                return const JoinedPoolContent();
              case PoolStatus.notJoined:
                return const PoolContent();
              case PoolStatus.addMore:
                return const PoolContent(
                  addMore: true,
                );
              default:
                return const PoolContent();
            }
          }
        },
      );
}

class PoolContent extends StatefulWidget {
  final bool addMore;

  const PoolContent({
    super.key,
    this.addMore = false,
  });

  @override
  PoolContentState createState() => PoolContentState();
}

class PoolContentState extends State<PoolContent> {
  final TextEditingController amountText =
      TextEditingController(text: cubits.pool.state.amount);
  bool amountDollars = false;
  bool automaticConversion = false;
  bool userChanged = false;

  @override
  void dispose() {
    amountText.dispose();
    super.dispose();
  }

  bool validateVisibleForm() => cubits.send.validateAmount(amountText.text);

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
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<PoolCubit, PoolState>(
              builder: (BuildContext context, PoolState state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    amountTextField(),
                  ],
                );
              },
            ),
            AppButton(
              onPressed: () => validateVisibleForm()
                  ? {
                      if (widget.addMore)
                        {
                          cubits.pool.update(
                            poolStatus: PoolStatus.joined,
                          )
                        }
                      else
                        {
                          cubits.pool.update(
                            poolStatus: PoolStatus.joined,
                          )
                        }
                    }
                  : cubits.toast.flash(
                      msg: const ToastMessage(
                        title: 'Unable to Continue:',
                        text: 'Invalid form',
                      ),
                    ),
              label: widget.addMore ? 'ADD TO POOL' : 'JOIN POOL',
            ),
          ],
        ),
      );

  GestureDetector amountTextField() {
    return GestureDetector(
      onDoubleTap: () async {
        if (amountDollars) {
          String potentialAmount =
              (await Clipboard.getData('text/plain'))?.text ?? '';
          try {
            final fiatAmount = Fiat(
              double.tryParse(
                    potentialAmount.trim().replaceAll(',', ''),
                  ) ??
                  0,
            );
            setState(() {
              amountText.text = fiatAmount.toString();
            });
          } catch (e) {
            see(e);
          }
        } else {
          amountText.text = cubits.holding.state.holding.coin.entire();
          setState(() {
            cubits.pool.update(
              amount: cubits.holding.state.holding.coin.entire(),
            );
          });
        }
      },
      child: CustomTextField(
        textInputAction: TextInputAction.done,
        controller: amountText,
        keyboardType:
            const TextInputType.numberWithOptions(signed: false, decimal: true),
        labelText: amountDollars ? 'Amount in USD' : 'Amount',
        errorText: amountDollars
            ? userChanged
                ? cubits.send
                    .invalidAmountMessages(Fiat(double.tryParse(
                                amountText.text.trim().replaceAll(',', '')) ??
                            0)
                        .toCoin(cubits.holding.state.holding.rate)
                        .toString())
                    .firstOrNull
                : cubits.send
                    .invalidAmountMessages(cubits.pool.state.amount)
                    .firstOrNull
            : amountText.text.trim() == '' ||
                    cubits.send.validateAmount(amountText.text)
                ? null
                : cubits.send.invalidAmountMessages(amountText.text).first,
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
                selection:
                    TextSelection.collapsed(offset: formattedValue.length),
              );
            }

            // Convert USD to coin amount for validation and cubit update
            final coinAmount = Fiat(double.tryParse(cleanValue) ?? 0)
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
                selection:
                    TextSelection.collapsed(offset: formattedValue.length),
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
    );
  }
}

class JoinedPoolContent extends StatefulWidget {
  const JoinedPoolContent({super.key});

  @override
  JoinedPoolContentState createState() => JoinedPoolContentState();
}

class JoinedPoolContentState extends State<JoinedPoolContent> {
  @override
  Widget build(BuildContext context) => Container(
        height: screen.pane.midHeight,
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              onPressed: () {
                // cubits.pool.addMore();
                cubits.pool.update(
                  poolStatus: PoolStatus.addMore,
                );
              },
              label: 'ADD MORE',
            ),
            const SizedBox(height: 8),
            AppButton(
              onPressed: () {
                showAppDialog(
                  context: context,
                  title: 'Leave Pool',
                  content: 'Are you sure you want to leave the pool?',
                  onYes: () {
                    cubits.pool.update(
                      poolStatus: PoolStatus.notJoined,
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
              label: 'LEAVE POOL',
            ),
          ],
        ),
      );
}
