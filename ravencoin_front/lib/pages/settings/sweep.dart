import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:wallet_utils/wallet_utils.dart' show FeeRate, FeeRates;
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/pages/misc/checkout.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/services/wallet.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class SweepPage extends StatefulWidget {
  @override
  _SweepPageState createState() => _SweepPageState();
}

class _SweepPageState extends State<SweepPage> {
  final FocusNode toFocus = FocusNode();
  final FocusNode feeFocus = FocusNode();
  final FocusNode memoFocus = FocusNode();
  final FocusNode noteFocus = FocusNode();
  final FocusNode submitFocus = FocusNode();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  //bool sweepCurrency = true;
  //bool sweepAssets = true;
  bool dropDownActive = false;
  String walletId = '';
  FeeRate fee = FeeRates.standard;
  String clipboard = '';
  bool clicked = false;

  @override
  void initState() {
    super.initState();
    fromController.text = Current.wallet.name;
    feeController.text = 'Standard';
  }

  @override
  void dispose() {
    toFocus.dispose();
    feeFocus.dispose();
    memoFocus.dispose();
    noteFocus.dispose();
    submitFocus.dispose();
    fromController.dispose();
    toController.dispose();
    feeController.dispose();
    memoController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BackdropLayers(
      back: const BlankBack(),
      front: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: FrontCurve(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          /// from
                          TextFieldFormatted(
                            controller: fromController,
                            readOnly: true,
                            labelText: 'From',
                            enabled: false,
                            onEditingComplete: () async {
                              FocusScope.of(context).requestFocus(toFocus);
                            },
                          ),
                          const SizedBox(height: 16),

                          /// to
                          TextFieldFormatted(
                            focusNode: toFocus,
                            controller: toController,
                            readOnly: true,
                            labelText: 'To',
                            suffixIcon: IconButton(
                              icon: const Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: Icon(Icons.expand_more_rounded,
                                      color: Color(0xDE000000))),
                              onPressed: _produceToModal,
                            ),
                            onTap: _produceToModal,
                            onEditingComplete: () async {
                              FocusScope.of(context).requestFocus(feeFocus);
                            },
                          ),
                          const SizedBox(height: 16),

                          /// fee
                          TextFieldFormatted(
                            focusNode: feeFocus,
                            controller: feeController,
                            readOnly: true,
                            textInputAction: TextInputAction.next,
                            labelText: 'Transaction Speed',
                            hintText: 'Standard',
                            suffixIcon: IconButton(
                              icon: const Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: Icon(Icons.expand_more_rounded,
                                      color: Color(0xDE000000))),
                              onPressed: () => _produceFeeModal(),
                            ),
                            onTap: () {
                              _produceFeeModal();
                              setState(() {});
                            },
                            onChanged: (String? newValue) {
                              FocusScope.of(context).requestFocus(memoFocus);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),

                          /// memo
                          TextFieldFormatted(
                              onTap: () async {
                                clipboard =
                                    (await Clipboard.getData('text/plain'))
                                            ?.text ??
                                        '';
                                setState(() {});
                              },
                              focusNode: memoFocus,
                              controller: memoController,
                              textInputAction: TextInputAction.next,
                              labelText: 'Memo',
                              hintText: 'IPFS',
                              helperText: memoFocus.hasFocus
                                  ? 'will be saved on the blockchain'
                                  : null,
                              helperStyle: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                      height: .7, color: AppColors.primary),
                              errorText: verifyMemo() ? null : 'too long',
                              suffixIcon:
                                  clipboard.isAssetData || clipboard.isIpfs
                                      ? IconButton(
                                          icon: const Icon(Icons.paste_rounded,
                                              color: AppColors.black60),
                                          onPressed: () async {
                                            memoController.text =
                                                (await Clipboard.getData(
                                                            'text/plain'))
                                                        ?.text ??
                                                    '';
                                          })
                                      : null,
                              onChanged: (String value) {
                                setState(() {});
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).requestFocus(noteFocus);
                                setState(() {});
                              }),
                          const SizedBox(height: 16),

                          /// note
                          TextFieldFormatted(
                              onTap: () async {
                                clipboard =
                                    (await Clipboard.getData('text/plain'))
                                            ?.text ??
                                        '';
                                setState(() {});
                              },
                              focusNode: noteFocus,
                              controller: noteController,
                              textInputAction: TextInputAction.next,
                              labelText: 'Note',
                              hintText: 'Purchase',
                              helperText: noteFocus.hasFocus
                                  ? 'will be saved to your phone'
                                  : null,
                              helperStyle: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                      height: .7, color: AppColors.primary),
                              suffixIcon: clipboard == '' ||
                                      clipboard.isIpfs ||
                                      clipboard.isAddressRVN ||
                                      clipboard.isAddressRVNt
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.paste_rounded,
                                          color: AppColors.black60),
                                      onPressed: () async {
                                        noteController.text =
                                            (await Clipboard.getData(
                                                        'text/plain'))
                                                    ?.text ??
                                                '';
                                      },
                                    ),
                              onChanged: (String value) {
                                setState(() {});
                              },
                              onEditingComplete: () {
                                FocusScope.of(context)
                                    .requestFocus(submitFocus);
                                setState(() {});
                              })
                        ])),
                KeyboardHidesWidgetWithDelay(
                  child: components.containers.navBar(context,
                      child: Row(children: <Widget>[submitButton])),
                )
              ]))));

  Future<void> _produceToModal() async {
    if (!dropDownActive) {
      dropDownActive = true;
      await SimpleSelectionItems(
        components.navigator.routeContext!,
        then: () => dropDownActive = false,
        items: <Widget>[
              ListTile(
                visualDensity: VisualDensity.compact,
                onTap: () async {
                  Navigator.pop(components.navigator.routeContext!);
                  walletId = await generateWallet();
                  toController.text =
                      pros.wallets.primaryIndex.getOne(walletId)!.name;
                },
                leading: const Icon(Icons.add, color: AppColors.primary),
                title: Text('New Wallet',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
            ] +
            <Widget>[
              for (Wallet wallet in pros.wallets.ordered)
                if (wallet.id != Current.walletId)
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    onTap: () async {
                      walletId = wallet.id;
                      toController.text = wallet.name;
                      Navigator.pop(components.navigator.routeContext!);
                    },
                    leading: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(wallet.name,
                        style: Theme.of(context).textTheme.bodyText1),
                  )
            ],
      ).build();
    }
    setState(() {});
    FocusScope.of(context).requestFocus(submitFocus);
  }

  Future<void> _produceFeeModal() async {
    if (!dropDownActive) {
      dropDownActive = true;
      await SimpleSelectionItems(
        components.navigator.routeContext!,
        then: () => dropDownActive = false,
        items: <Widget>[
          ListTile(
            visualDensity: VisualDensity.compact,
            onTap: () async {
              Navigator.pop(components.navigator.routeContext!);
              fee = FeeRates.standard;
              feeController.text = 'Standard';
            },
            leading: const Icon(MdiIcons.speedometerMedium,
                color: AppColors.primary),
            title:
                Text('Standard', style: Theme.of(context).textTheme.bodyText1),
          ),
          ListTile(
            visualDensity: VisualDensity.compact,
            onTap: () async {
              Navigator.pop(components.navigator.routeContext!);
              fee = FeeRates.fast;
              feeController.text = 'Fast';
            },
            leading: const Icon(MdiIcons.speedometer, color: AppColors.primary),
            title: Text('Fast', style: Theme.of(context).textTheme.bodyText1),
          ),
        ],
      ).build();
    }
    FocusScope.of(context).requestFocus(submitFocus);
  }

  bool verifyMemo([String? memo]) =>
      (memo ?? memoController.text).isMemo ||
      (memo ?? memoController.text).isIpfs;

  bool get enabled => toController.text != '' && walletId != '';

  Widget get submitButton => components.buttons.actionButton(
        context,
        focusNode: submitFocus,
        enabled: enabled && !clicked,
        label: !clicked ? 'Preview' : 'Generating Transaction...',
        onPressed: () {
          setState(() => clicked = true);
          confirmSend();
        },
        //link: '//password/change',
      );

  void confirmSend() {
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transaction/checkout',
      arguments: <String, CheckoutStruct>{
        'struct': CheckoutStruct(
          icon: const Icon(Icons.account_balance_wallet_rounded,
              color: AppColors.primary),
          symbol: null,
          displaySymbol: fromController.text,
          subSymbol: null,
          paymentSymbol: null,
          items: <List<String>>[
            <String>['To', toController.text],
            <String>['Amount', 'All Coins and Assets'],
            if (memoController.text != '')
              <String>['Memo', memoController.text],
            if (noteController.text != '')
              <String>['Note', noteController.text],
          ],
          fees: null,
          total: null,
          confirm:
              "Are you sure you want to sweep all of this wallet's coins and assets?",
          playcount: 10,
          buttonAction: () async {
            services.transaction.sweep(
                from: Current.wallet,
                toWalletId: walletId,
                currency: true,
                assets: true,
                memo: memoController.text == '' ? null : memoController.text,
                note: noteController.text == '' ? null : noteController.text);
            //await components.loading.screen(
            //  message: 'Sweeping',
            //  playCount: 3,
            //  returnHome: true,
            //);
            //streams.app.snack.add(Snack(message: 'Successfully Swept'));
          },
          buttonWord: 'Sweep',
          loadingMessage: 'Sweeping',
        )
      },
    );
    setState(() => clicked = false);
  }
}
