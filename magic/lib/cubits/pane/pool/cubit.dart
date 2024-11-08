import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';
part 'state.dart';

class PoolCubit extends UpdatableCubit<PoolState> {
  PoolCubit() : super(const PoolState());
  double height = 0;
  @override
  String get key => 'pool';
  @override
  void reset() => emit(const PoolState());
  @override
  void setState(PoolState state) => emit(state);
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
    String? amount,
    bool? isSubmitting,
    PoolStatus? poolStatus,
    PoolState? prior,
  }) {
    emit(PoolState(
      active: active ?? state.active,
      amount: amount ?? state.amount,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      poolStatus: poolStatus ?? state.poolStatus,
      prior: prior ?? state.withoutPrior,
    ));
  }
}
