part of 'cubit.dart';

enum PoolStatus { notJoined, joined, addMore }

class PoolState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final String amount;
  final Holding? poolHolding;
  final List<BalanceAddress>? balanceAddresses;
  final String poolAddress;
  final bool isSubmitting;
  final PoolStatus poolStatus;
  final PoolState? prior;

  const PoolState({
    this.active = false,
    this.amount = '',
    this.poolHolding,
    this.balanceAddresses,
    this.poolAddress = '',
    this.isSubmitting = false,
    this.poolStatus = PoolStatus.notJoined,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        amount,
        poolHolding,
        balanceAddresses,
        poolAddress,
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
        poolHolding: poolHolding,
        balanceAddresses: balanceAddresses,
        poolAddress: poolAddress,
        isSubmitting: isSubmitting,
        poolStatus: poolStatus,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
