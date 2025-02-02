part of 'cubit.dart';

class AppState with EquatableMixin {
  final AppLifecycleState status;
  final bool wasPaused;
  final StreamingConnectionStatus connection;
  final int blockheight;
  final DateTime? authenticatedAt;
  final bool submitting;
  final AppState? prior;

  const AppState({
    this.status = AppLifecycleState.inactive,
    this.wasPaused = false,
    this.connection = StreamingConnectionStatus.disconnected,
    this.blockheight = 0,
    this.authenticatedAt,
    this.submitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => [
        status,
        wasPaused,
        connection,
        blockheight,
        authenticatedAt,
        submitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  AppState get withoutPrior => AppState(
        status: status,
        wasPaused: wasPaused,
        connection: connection,
        blockheight: blockheight,
        authenticatedAt: authenticatedAt,
        submitting: submitting,
        prior: null,
      );
}
