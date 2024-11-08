import 'dart:async';

enum LockType { read, write }

// TODO: More robust checking, errors, etc for coder

// Multiple reads can happen at once
// Only one write can happen at once
// Reads cannot occur during writes.
// Writes cannot occur during reads.

// This class will always prioritize writes
// TODO: Do we want to prioritize reads sometimes or flip-flop between?
class ReaderWriterLock {
  int _readCount = 0;
  bool _isWritingOrWaitingToWrite = false;

  final List<Completer<void>> _writeQueue = <Completer<void>>[];
  Completer<void> _readAfterWrite = Completer();

  Future<T> lockScope<T>(
    T Function() callback, {
    required LockType lockType,
  }) async {
    lockType == LockType.write ? await enterWrite() : await enterRead();
    var x = callback();
    lockType == LockType.write ? await exitWrite() : await exitRead();
    return x;
  }

  Future<T> lockScopeFuture<T>(
    Future<T> Function() callback, {
    required LockType lockType,
  }) async {
    lockType == LockType.write ? await enterWrite() : await enterRead();
    var x = await callback();
    lockType == LockType.write ? await exitWrite() : await exitRead();
    return x;
  }

  Future<T> read<T>(T Function() fn) async =>
      await lockScope(fn, lockType: LockType.read);

  Future<T> write<T>(T Function() fn) async =>
      await lockScope(fn, lockType: LockType.write);

  Future<T> readFuture<T>(Future<T> Function() fn) async =>
      await lockScopeFuture(fn, lockType: LockType.read);

  Future<T> writeFuture<T>(Future<T> Function() fn) async =>
      await lockScopeFuture(fn, lockType: LockType.write);

  Future<void> enterRead() async {
    while (_isWritingOrWaitingToWrite) {
      await _readAfterWrite.future;
    }
    _readCount += 1;
  }

  Future<void> exitRead() async {
    _readCount -= 1;
    if (_readCount == 0 && _writeQueue.isNotEmpty) {
      _writeQueue.removeAt(0).complete();
    }
  }

  Future<void> enterWrite() async {
    final oldBool = _isWritingOrWaitingToWrite;
    _isWritingOrWaitingToWrite = true;
    if (oldBool || _readCount != 0) {
      final completer = Completer();
      _writeQueue.add(completer);
      await completer.future;
    }
  }

  Future<void> exitWrite() async {
    if (_writeQueue.isNotEmpty) {
      _writeQueue.removeAt(0).complete();
    } else {
      _isWritingOrWaitingToWrite = false;
      final oldCompleter = _readAfterWrite;
      _readAfterWrite = Completer();
      oldCompleter.complete();
    }
  }
}
