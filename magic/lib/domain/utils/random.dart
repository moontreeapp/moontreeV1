import 'dart:math';

// Extending the List class to include the 'random' getter
extension RandomElement<T> on List<T> {
  T get random {
    final random = Random();
    return this[random.nextInt(length)];
  }
}
