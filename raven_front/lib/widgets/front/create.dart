import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/params.dart';
import 'package:raven_back/utils/utilities.dart';
import 'package:raven_back/streams/create.dart';
import 'package:raven_front/utils/transformers.dart';
import 'package:raven_front/widgets/widgets.dart';

enum FormPresets {
  main,
  sub,
  restricted,
  qualifier,
  subQualifier,
  NFT,
  channel,
}

class CreateAsset extends StatefulWidget {
  static const int ipfsLength = 89;
  static const int quantityMax = 21000000;

  final FormPresets preset;
  final String? parent;

  CreateAsset({
    required this.preset,
    this.parent,
  }) : super();

  @override
  _CreateAssetState createState() => _CreateAssetState();
}

class _CreateAssetState extends State<CreateAsset> {
  List<StreamSubscription> listeners = [];
  GenericCreateForm? createForm;
  TextEditingController nameController = TextEditingController();
  TextEditingController ipfsController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController decimalController = TextEditingController();
  TextEditingController verifierController = TextEditingController();
  bool reissueValue = true;
  FocusNode nameFocus = FocusNode();
  FocusNode ipfsFocus = FocusNode();
  FocusNode nextFocus = FocusNode();
  FocusNode quantityFocus = FocusNode();
  FocusNode decimalFocus = FocusNode();
  FocusNode verifierFocus = FocusNode();
  bool nameValidated = false;
  bool ipfsValidated = false;
  bool quantityValidated = false;
  bool decimalValidated = false;
  String? nameValidationErr;
  bool verifierValidated = false;
  String? verifierValidationErr;
  int remainingNameLength = 31;
  int remainingVerifierLength = 89;
  Map<FormPresets, String> presetToTitle = {
    FormPresets.main: 'Asset Name',
    FormPresets.restricted: 'Restricted Asset Name',
    FormPresets.qualifier: 'Qualifier Name',
    FormPresets.NFT: 'NFT Name',
    FormPresets.channel: 'Message Channel Name',
  };

  @override
  void initState() {
    super.initState();
    remainingNameLength =
        // max asset length
        31 -
            // parent text and implied '/'
            (isSub ? widget.parent!.length + 1 : 0) -
            // everything else has a special character denoting its type
            (isMain ? 0 : 1);
    listeners.add(streams.create.form.listen((GenericCreateForm? value) {
      if (createForm != value) {
        setState(() {
          createForm = value;
          nameController.text = value?.name ?? nameController.text;
          ipfsController.text = value?.ipfs ?? ipfsController.text;
          quantityController.text =
              value?.quantity?.toString() ?? quantityController.text;
          decimalController.text = value?.decimal ?? decimalController.text;
          reissueValue = value?.reissuable ?? reissueValue;
          verifierController.text = value?.verifier ?? verifierController.text;
        });
      }
    }));
  }

  @override
  void dispose() {
    nameController.dispose();
    ipfsController.dispose();
    quantityController.dispose();
    decimalController.dispose();
    nameFocus.dispose();
    ipfsFocus.dispose();
    nextFocus.dispose();
    quantityFocus.dispose();
    decimalFocus.dispose();
    verifierController.dispose();
    verifierFocus.dispose();
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: body(),
      );

  bool get isSub => widget.parent != null;
  // above is shorthand, full logic:
  //    !isRestricted &&
  //    ((isNFT || isChannel) ||
  //        (isMain && widget.parent != null) ||
  //        (isQualifier && widget.parent != null));

  bool get isMain => widget.preset == FormPresets.main;
  bool get isNFT => widget.preset == FormPresets.NFT;
  bool get isChannel => widget.preset == FormPresets.channel;
  bool get isQualifier => widget.preset == FormPresets.qualifier;
  bool get isRestricted => widget.preset == FormPresets.restricted;

  bool get needsQuantity => isMain || isRestricted || isQualifier;
  bool get needsDecimal => isMain || isRestricted;
  bool get needsVerifier => isRestricted;
  bool get needsReissue => isMain || isRestricted;

  Widget body() => CustomScrollView(
          // solves scrolling while keyboard
          shrinkWrap: true,
          slivers: <Widget>[
            SliverToBoxAdapter(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: nameField(),
                        ),
                        if (needsQuantity)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: quantityField(),
                          ),
                        if (needsDecimal)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: decimalField(),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: ipfsField(),
                        ),
                        if (needsVerifier)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: verifierField(),
                          ),
                        if (needsReissue)
                          Padding(
                              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                              child: reissueRow()),
                      ]),
                ])),
            SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                    padding: EdgeInsets.only(bottom: 40, left: 16, right: 16),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [submitButton()])))
          ]);

  Widget nameField() => TextField(
      focusNode: nameFocus,
      autocorrect: false,
      controller: nameController,
      textInputAction: TextInputAction.done,
      keyboardType: isRestricted ? TextInputType.none : null,
      inputFormatters: [MainAssetNameTextFormatter()],
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: presetToTitle[widget.preset]!,
        hintText: 'MOONTREE_WALLET.COM',
        errorText: isChannel || isRestricted
            ? null
            : nameController.text.length > 2 &&
                    !nameValidation(nameController.text)
                ? nameValidationErr
                : null,
      ),
      onTap: isQualifier || isRestricted ? _produceAdminAssetModal : null,
      onChanged: isQualifier || isRestricted
          ? null
          : (String value) => validateName(name: value),
      onEditingComplete: isQualifier || isRestricted
          ? () => FocusScope.of(context).requestFocus(quantityFocus)
          : isNFT || isChannel
              ? () => FocusScope.of(context).requestFocus(ipfsFocus)
              : () {
                  formatName();
                  validateName();
                  FocusScope.of(context).requestFocus(quantityFocus);
                });

  Widget quantityField() => TextField(
        focusNode: quantityFocus,
        controller: quantityController,
//      keyboardType: TextInputType.number,
        keyboardType:
            TextInputType.numberWithOptions(decimal: false, signed: false),
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          // selection messed up: don't do it on edit, do it on complete,
          //CommaIntValueTextFormatter()
        ],
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'Quantity',
          hintText: '21,000,000',
          errorText: quantityController.text != '' &&
                  !quantityValidation(quantityController.text.toInt())
              ? 'must ${quantityController.text.toInt().toCommaString()} be between 1 and 21,000,000'
              : null,
        ),
        onChanged: (String value) => validateQuantity(quantity: value.toInt()),
        onEditingComplete: () {
          formatQuantity();
          FocusScope.of(context)
              .requestFocus(isQualifier ? ipfsFocus : decimalFocus);
        },
      );

  Widget decimalField() => TextField(
        focusNode: decimalFocus,
        controller: decimalController,
        readOnly: true,
        decoration: components.styles.decorations.textFeild(context,
            labelText: 'Decimals',
            hintText: 'Decimals',
            suffixIcon: IconButton(
              icon: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.expand_more_rounded,
                      color: Color(0xDE000000))),
              onPressed: () => _produceDecimalModal(),
            )),
        onTap: () => _produceDecimalModal(),
        onChanged: (String? newValue) {
          FocusScope.of(context).requestFocus(ipfsFocus);
          setState(() {});
        },
      );

  Widget verifierField() => TextField(
      focusNode: verifierFocus,
      autocorrect: false,
      controller: verifierController,
      textInputAction: TextInputAction.done,
      inputFormatters: [VerifierStringTextFormatter()],
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'Verifier String',
        hintText: '((#KYC & #ACCREDITED) | #EXEMPT) & !#IRS',
        errorText: verifierController.text.length > 2 &&
                !verifierValidation(verifierController.text)
            ? verifierValidationErr
            : null,
      ),
      onChanged: (String value) => validateVerifier(verifier: value),
      onEditingComplete: () {
        validateVerifier();
        FocusScope.of(context).requestFocus(ipfsFocus);
      });

  Widget ipfsField() => TextField(
        focusNode: ipfsFocus,
        autocorrect: false,
        controller: ipfsController,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'IPFS/Txid',
          hintText: 'QmUnMkaEB5FBMDhjPsEtLyHr4ShSAoHUrwqVryCeuMosNr',
          //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
          errorText: !ipfsValidation(ipfsController.text)
              ? '${CreateAsset.ipfsLength - ipfsController.text.length}'
              : null,
        ),
        onChanged: (String value) => validateIPFS(ipfs: value),
        onEditingComplete: () => FocusScope.of(context).requestFocus(nextFocus),
      );

  Widget reissueRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: Text('Reissuable asset can increase in quantity and '
                      'decimal in the future.\n\nNon-reissuable '
                      'assets cannot be modified in anyway.'),
                ),
              ),
              icon: const Icon(
                Icons.help_rounded,
                color: Colors.black,
              ),
            ),
            Text('Reissuable', style: Theme.of(context).switchText),
          ]),
          Switch(
            value: reissueValue,
            activeColor: Theme.of(context).backgroundColor,
            onChanged: (bool value) {
              setState(() {
                reissueValue = value;
              });
            },
          )
        ],
      );

  Widget submitButton() => Container(
      height: 40,
      child: OutlinedButton.icon(
          focusNode: nextFocus,
          onPressed: enabled ? () => submit() : () {},
          icon: Icon(
            Icons.chevron_right_rounded,
            color: enabled ? null : Color(0x61000000),
          ),
          label: Text(
            'NEXT',
            style: enabled
                ? Theme.of(context).enabledButton
                : Theme.of(context).disabledButton,
          ),
          style: components.styles.buttons.bottom(
            context,
            disabled: !enabled,
          )));

  bool nameValidation(String name) {
    if (!(name.length > 2 && name.length <= remainingNameLength)) {
      nameValidationErr = '${remainingNameLength - nameController.text.length}';
      return false;
    } else if (name.endsWith('.') || name.endsWith('_')) {
      nameValidationErr = 'cannot end with special character';
      return false;
    }
    nameValidationErr = null;
    return true;
  }

  void validateName({String? name}) {
    name = name ?? nameController.text;
    var oldValidation = nameValidated;
    nameValidated = nameValidation(name);
    if (oldValidation != nameValidated || !nameValidated) {
      setState(() => {});
    }
  }

  bool verifierValidation(String verifier) {
    if (verifier.length > remainingVerifierLength) {
      verifierValidationErr =
          '${remainingVerifierLength - verifierController.text.length}';
      return false;
      //} else if (verifier.endsWith('.') || verifier.endsWith('_')) {
      //  verifierValidationErr = 'allowed characters: A-Z, 0-9, (._#&|!)';
      //  ret = false;
    } else if ('('.allMatches(verifier).length !=
        ')'.allMatches(verifier).length) {
      verifierValidationErr =
          '${'('.allMatches(verifier).length} open parenthesis, '
          '${')'.allMatches(verifier).length} closed parenthesis';
      return false;
    }
    verifierValidationErr = null;
    return true;
  }

  void validateVerifier({String? verifier}) {
    verifier = verifier ?? verifierController.text;
    var oldValidation = verifierValidated;
    verifierValidated = verifierValidation(verifier);
    if (oldValidation != verifierValidated || !verifierValidated) {
      setState(() => {});
    }
  }

  bool ipfsValidation(String ipfs) => ipfs.length <= CreateAsset.ipfsLength;

  void validateIPFS({String? ipfs}) {
    ipfs = ipfs ?? ipfsController.text;
    var oldValidation = ipfsValidated;
    ipfsValidated = ipfsValidation(ipfs);
    if (oldValidation != ipfsValidated || !ipfsValidated) {
      setState(() => {});
    }
  }

  bool quantityValidation(int quantity) =>
      quantityController.text != '' &&
      quantity <= CreateAsset.quantityMax &&
      quantity > 0;

  void validateQuantity({int? quantity}) {
    quantity = quantity ?? quantityController.text.toInt();
    var oldValidation = quantityValidated;
    quantityValidated = quantityValidation(quantity);
    if (oldValidation != quantityValidated || !quantityValidated) {
      setState(() => {});
    }
  }

  bool decimalValidation(int decimal) =>
      decimalController.text != '' && decimal >= 0 && decimal <= 8;

  void validateDecimal({int? decimal}) {
    decimal = decimal ?? decimalController.text.toInt();
    var oldValidation = decimalValidated;
    decimalValidated = decimalValidation(decimal);
    if (oldValidation != decimalValidated || !decimalValidated) {
      setState(() => {});
    }
  }

  bool get enabled =>
      nameController.text.length > 2 &&
      nameValidation(nameController.text) &&
      (needsQuantity
          ? quantityController.text != '' &&
              quantityValidation(quantityController.text.toInt())
          : true) &&
      (needsDecimal
          ? decimalController.text != '' &&
              decimalValidation(decimalController.text.toInt())
          : true) &&
      (isNFT ? ipfsController.text != '' : true) &&
      ipfsValidation(ipfsController.text);

  void submit() {
    if (enabled) {
      FocusScope.of(context).unfocus();

      /// send them to transaction checkout screen
      checkout(GenericCreateRequest(
        name: nameController.text,
        ipfs: ipfsController.text,
        quantity: needsQuantity ? quantityController.text.toInt() : null,
        decimals: needsDecimal ? decimalController.text.toInt() : null,
        reissuable: needsReissue ? reissueValue : null,
        verifier: needsVerifier ? verifierController.text : null,
        parent: isSub ? widget.parent : null,
      ));
    }
  }

  void checkout(GenericCreateRequest createRequest) {
    /// send request to the correct stream
    //streams.spend.make.add(createRequest);

    /// go to confirmation page
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transaction/checkout',
      arguments: {
        'struct': CheckoutStruct(
          /// get the name we're creating the Asset under
          //symbol: ((streams.spend.form.value?.symbol == 'Ravencoin'
          //        ? 'RVN'
          //        : streams.spend.form.value?.symbol) ??
          //    'RVN'),
          subSymbol: '',
          paymentSymbol: 'RVN',
          items: [
            /// send the correct items
            if (isSub)
              [
                'Parent',
                '${widget.parent}/${isNFT || isQualifier ? '#' : isChannel ? '~' : ''}',
                '2'
              ],
            ['Asset Name', nameController.text, '2'],
            if (needsQuantity) ['Quantity', quantityController.text],
            if (needsDecimal) ['Decimals', decimalController.text],
            ['IPFS/Txid', ipfsController.text, '9'],
            if (needsVerifier)
              ['Verifier String', verifierController.text, '6'],
            if (needsReissue)
              [
                'Reissuable',
                reissueValue
                    ? 'Yes'
                    : 'NO  (WARNING: These settings will be PERMANENT forever!)',
                '3'
              ],
          ],
          fees: [
            ['Transaction Fee', 'calculating fee...']
          ],
          total: 'calculating total...',
          buttonAction: () => null,

          /// send the MainCreate request to the right stream
          //streams.spend.send.add(streams.spend.made.value),
          buttonIcon: MdiIcons.arrowTopRightThick,
          buttonWord: 'Create',
        )
      },
    );
  }

  void formatName() {
    nameController.text = nameController.text.substring(0, remainingNameLength);
    if (nameController.text.endsWith('_') ||
        nameController.text.endsWith('.')) {
      nameController.text =
          nameController.text.substring(0, nameController.text.length - 1);
    }
  }

  void formatQuantity() =>
      quantityController.text = quantityController.text.isInt
          ? quantityController.text.toInt().toCommaString()
          : quantityController.text;

  void _produceDecimalModal() {
    SelectionItems(context, modalSet: SelectionSet.Decimal)
        .build(decimalPrefix: quantityController.text);
  }

  void _produceAdminAssetModal() {
    SelectionItems(context, modalSet: SelectionSet.Admins).build(
        holdingNames: Current.adminNames
            .map((String name) => name.replaceAll('!', ''))
            .toList());
  }
}