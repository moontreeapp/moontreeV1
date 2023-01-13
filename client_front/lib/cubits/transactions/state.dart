part of 'cubit.dart';

@immutable
class TransactionsViewState extends CubitState {
  final List<TransactionView> transactionViews;
  final AssetMetadata? metadataView;
  final Wallet wallet;
  final Security security;
  final bool end;
  final BehaviorSubject<double> scrollObserver;
  final BehaviorSubject<String> currentTab;
  final bool isSubmitting;
  // allows us to remember what the wallet and security was last time we called
  // for transactionViews so that we never hit the endpoint multiple times with
  // the same input as last time. This also allows us to set the wallet and
  // security immediately, showing on coinspec while we wait for the views.
  final Wallet? ranWallet;
  final Security? ranSecurity;
  final int? ranHeight;

  const TransactionsViewState({
    required this.transactionViews,
    required this.metadataView,
    required this.scrollObserver,
    required this.currentTab,
    required this.wallet,
    required this.security,
    required this.end,
    required this.isSubmitting,
    required this.ranWallet,
    required this.ranSecurity,
    required this.ranHeight,
  });

  TransactionsViewState reset() {
    scrollObserver.close();
    currentTab.close();
    return this;
  }

  @override
  String toString() => 'TransactionsView( '
      'transactionViews=$transactionViews, metadataView=$metadataView, '
      'wallet=$wallet, security=$security, end=$end, ranWallet=$ranWallet, '
      'ranSecurity=$ranSecurity, ranHeight=$ranHeight, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        transactionViews,
        metadataView,
        wallet,
        security,
        end,
        ranWallet,
        ranSecurity,
        ranHeight,
        isSubmitting,
      ];

  factory TransactionsViewState.initial() => TransactionsViewState(
      transactionViews: [],
      metadataView: null,
      scrollObserver: BehaviorSubject<double>.seeded(.7),
      currentTab: BehaviorSubject<String>.seeded('HISTORY'),
      wallet: pros.wallets.currentWallet,
      security: pros.securities.currentCoin,
      end: false,
      ranWallet: null,
      ranSecurity: null,
      ranHeight: null,
      isSubmitting: true);

  TransactionsViewState load({
    List<TransactionView>? transactionViews,
    AssetMetadata? metadataView,
    Wallet? wallet,
    Security? security,
    bool? end,
    Wallet? ranWallet,
    Security? ranSecurity,
    int? ranHeight,
    bool? isSubmitting,
  }) =>
      TransactionsViewState.load(
        state: this,
        transactionViews: transactionViews,
        metadataView: metadataView,
        wallet: wallet,
        security: security,
        end: end,
        ranWallet: ranWallet,
        ranSecurity: ranSecurity,
        ranHeight: ranHeight,
        isSubmitting: isSubmitting,
      );

  factory TransactionsViewState.load({
    required TransactionsViewState state,
    List<TransactionView>? transactionViews,
    AssetMetadata? metadataView,
    Wallet? wallet,
    Security? security,
    bool? end,
    Wallet? ranWallet,
    Security? ranSecurity,
    int? ranHeight,
    bool? isSubmitting,
  }) =>
      TransactionsViewState(
        transactionViews: transactionViews ?? state.transactionViews,
        metadataView: metadataView ?? state.metadataView,
        wallet: wallet ?? state.wallet,
        security: security ?? state.security,
        end: end ?? state.end,
        ranWallet: ranWallet ?? state.ranWallet,
        ranSecurity: ranSecurity ?? state.ranSecurity,
        ranHeight: ranHeight ?? state.ranHeight,
        isSubmitting: isSubmitting ?? state.isSubmitting,
        scrollObserver: state.scrollObserver,
        currentTab: state.currentTab,
      );

  int? get lowestHeight => transactionViews.isEmpty
      ? null
      : transactionViews.map((e) => e.height).reduce(min) - 1;
}
