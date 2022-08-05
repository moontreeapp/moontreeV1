import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/theme/extensions.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ravencoin_back/services/transaction/transaction.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/components/components.dart';

class TransactionPage extends StatefulWidget {
  final dynamic data;
  const TransactionPage({this.data}) : super();

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  dynamic data = {};
  Address? address;
  List<StreamSubscription> listeners = [];
  TransactionRecord? transactionRecord;
  Transaction? transaction;

  @override
  void initState() {
    super.initState();
    listeners.add(pros.blocks.changes.listen((changes) {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    transactionRecord = data['transactionRecord'];
    transaction = transactionRecord!.transaction;
    //address = addresses.primaryIndex.getOne(transaction!.addresses);
    return BackdropLayers(
      back: BlankBack(),
      front: FrontCurve(child: detailsBody()),
    );
  }

  String element(String humanName) {
    switch (humanName) {
      case 'Date':
        return getDateBetweenHelper();
      case 'Confirmations':
        return getConfirmationsBetweenHelper();
      case 'Type':
        switch (transactionRecord!.type) {
          case TransactionRecordType.SELF:
            return 'to Self';
          case TransactionRecordType.FEE:
            return 'Asset Transfer Fee';
          case TransactionRecordType.ASSETCREATION:
            return 'Asset Creation';
          case TransactionRecordType.BURN:
            return 'Burned';
          case TransactionRecordType.REISSUE:
            return 'Reissue';
          case TransactionRecordType.TAG:
            return 'Tag';
          case TransactionRecordType.INCOMING:
            return 'In';
          case TransactionRecordType.OUTGOING:
            //default:
            return 'Out';
        }
      case 'ID':
        return transaction!.id.cutOutMiddle();
      case 'Memo/IPFS':
        return (String humanName) {
          var txMemo = (transactionMemo ?? '');
          if (txMemo.isIpfs) {
            return txMemo.cutOutMiddle();
          }
          if (txMemo.length > 30) {
            return txMemo.cutOutMiddle(length: 12);
          }
          return txMemo;
        }(humanName);
      case 'Note':
        return transaction!.note ?? '';
      case 'Fee':
        return transactionRecord!.fee.toAmount().toCommaString() + ' RVN';
      default:
        return 'unknown';
    }
  }

  String? get transactionMemo {
    // should do this logic on the back / in the record
    return transaction!.memos.isNotEmpty
        ? transaction!.memos.first.substring(2).hexToUTF8
        : transaction!.assetMemos.isNotEmpty
            ? transaction!.assetMemos.first /*.hexToAscii ?*/
            : null;
  }

  String elementFull(String humanName) {
    switch (humanName) {
      case 'ID':
        return transaction!.id;
      case 'Memo/IPFS':
        return transactionMemo ?? '';
      case 'Note':
        return transaction!.note ?? '';
      default:
        return 'unknown';
    }
  }

  Widget plain(String text, String value) => ListTile(
        dense: true,
        title: Text(text, style: Theme.of(context).textTheme.bodyText1),
        trailing: GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: value));
            streams.app.snack
                .add(Snack(message: 'Copied to Clipboard', atBottom: true));
          },
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: text == 'Memo/IPFS' && !value.isIpfs ? 3 : null,
          ),
        ),
      );

  Widget link({
    required String title,
    required String text,
    required String url,
    required String description,
  }) =>
      ListTile(
        dense: true,
        title: Text(text, style: Theme.of(context).textTheme.bodyText1),
        onTap: () => components.message.giveChoices(
          context,
          title: title,
          content: 'View ${description} in external browser?',
          behaviors: {
            'Cancel'.toUpperCase(): Navigator.of(context).pop,
            'Browser'.toUpperCase(): () {
              Navigator.of(context).pop();
              //launch(url + elementFull(text));
              launchUrl(Uri.parse(url + elementFull(text)));
            },
          },
        ),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: elementFull(text)));
          streams.app.snack
              .add(Snack(message: 'Copied to Clipboard', atBottom: true));
        },
        trailing: Text(element(text), style: Theme.of(context).textTheme.link),
      );

  Widget detailsBody() => ListView(
        padding: EdgeInsets.only(top: 8, bottom: 112),
        children: <Widget>[
              for (var text in ['Date', 'Confirmations', 'Type', 'Fee'])
                plain(text, element(text))
            ] +
            [
              link(
                title: 'Transaction Info',
                text: 'ID',
                url:
                    'https://rvn${pros.settings.mainnet ? '' : 't'}.cryptoscope.io/tx/?txid=',
                description: 'info',
              ),
              if (transactionMemo != null)
                transactionMemo!.isIpfs
                    ? link(
                        title: 'IPFS',
                        text: 'Memo/IPFS',
                        url: 'https://gateway.ipfs.io/ipfs/',
                        description: 'data',
                      )
                    : plain('Memo/IPFS', element('Memo/IPFS')),
            ] +
            (transaction!.note == null || transaction!.note == ''
                ? []
                : [plain('Note', element('Note'))]),
      );

  int? getBlocksBetweenHelper({Transaction? tx, Block? current}) {
    tx = tx ?? transaction!;
    current = current ?? pros.blocks.latest;
    return (current != null && tx.height != null)
        ? current.height - tx.height!
        : null;
  }

  String getDateBetweenHelper() => 'Date: ' + transaction!.formattedDatetime;
  //(getBlocksBetweenHelper() != null
  //    ? formatDate(
  //        DateTime.now().subtract(Duration(
  //          days: (getBlocksBetweenHelper()! / 1440).floor(),
  //          hours:
  //              (((getBlocksBetweenHelper()! / 1440) % 1440) / 60).floor(),
  //        )),
  //        [MM, ' ', d, ', ', yyyy])
  //    : 'unknown');

  String getConfirmationsBetweenHelper() => (getBlocksBetweenHelper() != null
      ? getBlocksBetweenHelper().toString()
      : 'unknown');
}