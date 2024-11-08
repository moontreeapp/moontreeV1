part of 'cubit.dart';

enum PoolStatus { notJoined, joined, addMore }

class PoolState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final String amount;
  final bool isSubmitting;
  final PoolStatus poolStatus;
  final PoolState? prior;

  const PoolState({
    this.active = false,
    this.amount = '',
    this.isSubmitting = false,
    this.poolStatus = PoolStatus.notJoined,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        amount,
        isSubmitting,
        poolStatus,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  PoolState get withoutPrior => PoolState(
        active: active,
        amount: amount,
        isSubmitting: isSubmitting,
        poolStatus: poolStatus,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
