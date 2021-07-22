/// A collection of exceptions thrown by transcribers.

class NoAvailableModel implements Exception {
  final String message;
  NoAvailableModel([this.message]);
}

class TranscriberAlreadyInitialized implements Exception {
  final String message;
  TranscriberAlreadyInitialized([this.message]);
}

class TranscriberNotInitialized implements Exception {
  final String message;
  TranscriberNotInitialized([this.message]);
}
