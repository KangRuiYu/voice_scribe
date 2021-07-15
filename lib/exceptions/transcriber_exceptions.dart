/// A collection of exceptions thrown by transcribers.

class NoAvailableModel implements Exception {
  static const String _message =
      'Attempted to transcribe when application does not have access to a model.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class TranscriberAlreadyInitialized implements Exception {
  static const String _message =
      'Attempted to initialize an already initialized transcriber.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class TranscriberNotInitialized implements Exception {
  static const String _message =
      'Attempted to use a transcriber that has not been initialized.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}
