import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/theme.dart';

class TransactionList extends StatefulWidget {
  final Iterable<TransactionRecord>? transactions;
  final String? msg;
  final ScrollController? scrollController;

  const TransactionList({
    this.transactions,
    this.msg,
    this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  //widget.currentAccountId //  we don't rebuild on this, we're given it.
  List<StreamSubscription> listeners = [];
  late Iterable<TransactionRecord> transactions;
  bool showUSD = false;
  Rate? rateUSD;
  int transactionCount = 1;

  @override
  void initState() {
    super.initState();
    listeners.add(
        res.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      // if vouts in our account has changed...
      var items = batchedChanges
          .where((change) => change.data.address?.walletId == Current.walletId);
      if (items.isNotEmpty) {
        setState(() {
          transactionCount = items.length;
        });
      }
    }));
    listeners.add(res.rates.batchedChanges.listen((batchedChanges) {
      // ignore: todo
      // TODO: should probably include any assets that are in the holding of the main account too...
      var changes = batchedChanges.where((change) =>
          change.data.base == res.securities.RVN &&
          change.data.quote == res.securities.USD);
      if (changes.isNotEmpty)
        setState(() {
          rateUSD = changes.first.data;
        });
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  Future refresh() async {
    await services.rate.saveRate();
    await services.balance.recalculateAllBalances();
    setState(() {});
    // showing snackbar
    //_scaffoldKey.currentState.showSnackBar(
    //  SnackBar(
    //    content: const Text('Page Refreshed'),
    //  ),
    //);
  }

  @override
  Widget build(BuildContext context) {
    transactions = widget.transactions ??
        services.transaction.getTransactionRecords(wallet: Current.wallet);
    return transactions.isEmpty
        //? components.empty.transactions(context, msg: widget.msg)
        ? components.empty.gettingTransactionsPlaceholder(context,
            scrollController: widget.scrollController!, count: transactionCount)
        : Container(
            alignment: Alignment.center,
            child: RefreshIndicator(
              child: _transactionsView(context),
              onRefresh: () => refresh(),
            ));
  }

  ListView _transactionsView(BuildContext context) =>
      ListView(controller: widget.scrollController, children: <Widget>[
        SizedBox(height: 16),
        ...[
              for (var transactionRecord in transactions) ...[
                ...[
                  ListTile(
                    //contentPadding:
                    //    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 13),
                    onTap: () => Navigator.pushNamed(
                        context, '/transaction/transaction',
                        arguments: {'transactionRecord': transactionRecord}),
                    //onLongPress: _toggleUSD,
                    //leading: Container(
                    //    height: 40,
                    //    width: 40,
                    //    child: components.icons
                    //        .assetAvatar(transactionRecord.security.symbol)),
                    title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              //() {
                              //  var amountToDisplay = components.text.securityAsReadable(
                              //      transactionRecord.value,
                              //      security: transactionRecord.security,
                              //      asUSD: showUSD);
                              //  return amountToDisplay == '0'
                              //      ? 'sent to self'
                              //      : amountToDisplay;
                              //}()
                              transactionRecord.toSelf
                                  ? 'Sent to Self'
                                  : components.text.securityAsReadable(
                                      transactionRecord.value,
                                      security: transactionRecord.security,
                                      asUSD: showUSD),
                              style: Theme.of(context).textTheme.bodyText1),
                          Text(transactionRecord.formattedDatetime,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(color: AppColors.black60)),
                        ]),
                    trailing: (transactionRecord.out
                        ? components.icons.out(context)
                        : components.icons.income(context)),
                  ),
                  Divider(indent: 16),
                ]
              ]
            ] +
            [
              Container(
                height: 118,
                color: Colors.white,
              )
            ]
      ]);
}