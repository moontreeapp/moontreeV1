import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class SendCubit extends UpdatableCubit<SendState> {
  SendCubit() : super(const SendState());
  double height = 0;
  @override
  String get key => 'send';
  @override
  void reset() => emit(const SendState());
  @override
  void setState(SendState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void refresh() {
    update(isSubmitting: false);
    update(isSubmitting: true);
  }

  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);
  @override
  void update({
    bool? active,
    String? asset,
    double? amount,
    bool? isSubmitting,
    SendState? prior,
  }) {
    emit(SendState(
      active: active ?? state.active,
      asset: asset ?? state.asset,
      amount: amount ?? state.amount,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }
}