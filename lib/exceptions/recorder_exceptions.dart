/*
A collections of exceptions thrown by the recorder.
 */

class RecorderAlreadyInitializedException implements Exception {
  static const String _message =
      'Attempted to initialize an already initialized Recorder.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class RecorderAlreadyClosedException implements Exception {
  static const String _message = 'Attempted to close a non-open Recorder';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class RecorderNotInitializedException implements Exception {
  final String _message;
  RecorderNotInitializedException(this._message);

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class RecorderAlreadyStopped implements Exception {
  static const String _message =
      'Attempted to stop an already stopped recorder';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}
