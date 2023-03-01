//todo: merge the streams and listener into this.

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:client_back/server/src/protocol/comm_unsigned_transaction_result_class.dart';
import 'package:client_front/infrastructure/repos/unsigned.dart';
import 'package:flutter/material.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show AmountToSatsExtension, FeeRate, standardFee;
import 'package:client_back/client_back.dart';
import 'package:client_front/application/common.dart';
import 'package:client_back/services/wallet/constants.dart';
import 'package:client_front/infrastructure/services/storage.dart';

part 'state.dart';

class ImportFormCubit extends Cubit<ImportFormState> with SetCubitMixin {
  ImportFormCubit() : super(ImportFormState.initial());

  @override
  Future<void> reset() async => emit(ImportFormState.initial());

  @override
  ImportFormState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    emit(state);
  }

  @override
  void set({
    String? words,
    bool? importEnabled,
    String? importFormatDetected,
    String? password,
    String? salt,
    bool? importVisible,
    bool? submittedAttempt,
    ImportFormat? detection,
    FileDetails? file,
    String? finalText,
    String? finalAccountId,
    bool? isSubmitting,
  }) {
    emit(state.load(
      words: words,
      importEnabled: importEnabled,
      importFormatDetected: importFormatDetected,
      password: password,
      salt: salt,
      importVisible: importVisible,
      submittedAttempt: submittedAttempt,
      detection: detection,
      file: file,
      finalText: finalText,
      finalAccountId: finalAccountId,
      isSubmitting: isSubmitting,
    ));
  }

  bool validateValue(String? given) =>
      services.wallet.import.detectImportType((given ?? state.words).trim()) !=
      ImportFormat.invalid;

  void enableImport({String? given}) {
    String words = (given ?? state.words);
    final detection = services.wallet.import.detectImportType(words.trim());
    final importEnabled = detection != ImportFormat.invalid;
    late String? importFormatDetected;
    if (importEnabled) {
      importFormatDetected =
          'format recognized as ${detection.toString().split('.')[1]}';
    } else {
      importFormatDetected = '';
    }
    if (detection == ImportFormat.mnemonic) {
      words = state.words.toLowerCase();
    } else if (detection == ImportFormat.invalid) {
      importFormatDetected = 'Unknown';
    }
    set(
      detection: detection,
      importEnabled: importEnabled,
      importFormatDetected: importFormatDetected,
      words: words,
    );
  }
}
