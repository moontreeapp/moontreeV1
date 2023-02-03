import 'dart:typed_data';

import 'package:client_back/server/serverv2_client.dart';
import 'package:bloc/bloc.dart';
import 'package:client_front/infrastructure/repos/transaction.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/application/common.dart';
part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class TransactionViewCubit extends Cubit<TransactionViewState>
    with SetCubitMixin {
  String? priorPage;

  TransactionViewCubit() : super(TransactionViewState.initial()) {
    init();
  }

  @override
  Future<void> reset() async => emit(TransactionViewState.initial());

  @override
  TransactionViewState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    //emit(submitting());
    emit(state);
  }

  @override
  void set({
    TransactionDetailsView? transactionView,
    ByteData? ranHash,
    bool? isSubmitting,
  }) {
    //emit(submitting());
    emit(state.load(
      transactionView: transactionView,
      ranHash: ranHash,
      isSubmitting: isSubmitting,
    ));
  }

  void init() {
    streams.app.page.listen((String value) {
      if (value == 'Transactions' && priorPage == 'Transaction') {
        reset();
      }
      priorPage = value;
    });
  }

  Future<void> setTransactionDetails({
    required ByteData hash,
    bool force = false,
  }) async {
    if (force || (state.ranHash != hash && !state.isSubmitting)) {
      set(transactionView: null, isSubmitting: true);
      set(
        transactionView: await TransactionDetailsRepo(hash: hash).get(),
        ranHash: hash,
        isSubmitting: false,
      );
    }
  }

  void clearCache() => set(transactionView: null);
}