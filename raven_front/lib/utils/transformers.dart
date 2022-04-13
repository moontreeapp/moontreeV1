import 'package:flutter/services.dart';
import 'package:raven_back/extensions/extensions.dart';
import 'package:raven_back/utilities/utilities.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class MainAssetNameTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.toUpperCase();
    text = ['RVN', 'RAVEN', 'RAVENCOIN'].contains(text)
        ? ''
        : text
            .replaceAll('..', '.')
            .replaceAll('._', '.')
            .replaceAll('__', '_')
            .replaceAll('_.', '_')
            .replaceAll('//', '/');
    if (text.startsWith('_') || text.startsWith('.')) {
      text = text.substring(1, text.length);
    }
    if (newValue.text.length == text.length) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    }
    return TextEditingValue(
      text: text,
      selection: newValue.selection.baseOffset < oldValue.selection.baseOffset
          ? newValue.selection
          : oldValue.selection,
    );
  }
}

class CommaIntValueTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.isInt
        ? newValue.text.toInt().toCommaString()
        : newValue.text;
    if (newValue.text.length == text.length) {
      return newValue;
    }
    return TextEditingValue(
      text: text,
      //selection: oldValue.selection,
      //selection: newValue.selection.copyWith(
      //    baseOffset: newValue.selection.baseOffset + 2,
      //    extentOffset: newValue.selection.extentOffset + 2),
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class VerifierStringTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = utils.removeCharsOtherThan(newValue.text.toUpperCase(),
        chars: utils.strings.verifierStringAllowed);
    if (newValue.text.length == text.length) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    }
    return TextEditingValue(
      text: text,
      selection: oldValue.selection,
    );
  }
}
