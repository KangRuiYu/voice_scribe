/*
A collections of exceptions thrown by the recorder.
 */

class RecorderAlreadyInitializedException implements Exception {
  final String message;
  RecorderAlreadyInitializedException([this.message]);
}

class RecorderAlreadyClosedException implements Exception {
  final String message;
  RecorderAlreadyClosedException([this.message]);
}

class RecorderNotInitializedException implements Exception {
  final String message;
  RecorderNotInitializedException([this.message]);
}

class RecorderAlreadyStopped implements Exception {
  final String message;
  RecorderAlreadyStopped([this.message]);
}
