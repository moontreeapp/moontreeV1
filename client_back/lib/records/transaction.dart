import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:date_format/date_format.dart';

import '_type_id.dart';

part 'transaction.g.dart';

@HiveType(typeId: TypeId.Transaction)
class Transaction with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final bool confirmed; // why? this is height data.

  @HiveField(2)
  final int? time; //seconds since epoch

  @HiveField(3)
  final int? height;

  /// other possible tx elements from transaction.get
  //final String hash;
  //final int version;
  //final int size;
  //final int vsize;
  //final int locktime;
  //final String hex;
  //final String blockhash;
  //final int time;
  //final int blocktime;
  //final int confirmations;
  //// confirmations is
  //// -1 if the transaction is still in the mempool.
  //// 0 if its in the most recent block.
  //// 1 if another block has passed.

  const Transaction({
    required this.id,
    required this.confirmed,
    this.time,
    this.height,
  });

  @override
  List<Object?> get props => <Object?>[
        height,
        confirmed,
        time,
        id,
      ];

  @override
  String toString() {
    return 'Transaction('
        'id: $id, height: $height, confirmed: $confirmed, time: $time)';
  }

  // technically belongs on frontend...
  DateTime get datetime =>
      DateTime.fromMillisecondsSinceEpoch((time ?? 0) * 1000);

  String get formattedDatetime => time != null
      ? formatDate(datetime, <String>[MM, ' ', d, ', ', yyyy])
      : 'In Transit';
}
