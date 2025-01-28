import 'package:equatable/equatable.dart';

class BalanceAddress extends Equatable {
  final String symbol;
  final List<String> addresses;

  const BalanceAddress({
    required this.symbol,
    required this.addresses,
  });

  factory BalanceAddress.fromMap(MapEntry<String, dynamic> entry) {
    return BalanceAddress(
      symbol: entry.key,
      addresses:
          (entry.value as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
    );
  }

  /// Convert to map format
  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'addresses': addresses,
    };
  }

  @override
  List<Object?> get props => [symbol, addresses];

  @override
  String toString() => 'BalanceAddress(symbol: $symbol, addresses: $addresses)';
}
