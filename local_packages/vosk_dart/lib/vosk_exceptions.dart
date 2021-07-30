class ThreadAlreadyAllocated implements Exception {
  final String message;
  ThreadAlreadyAllocated([this.message]);
}

class ModelAlreadyOpened implements Exception {
  final String message;
  ModelAlreadyOpened([this.message]);
}

class NonExistentModel implements Exception {
  final String message;
  NonExistentModel([this.message]);
}

class NoOpenThread implements Exception {
  final String message;
  NoOpenThread([this.message]);
}

class NoOpenModel implements Exception {
  final String message;
  NoOpenModel([this.message]);
}

class NonExistentWavFile implements Exception {
  final String message;
  NonExistentWavFile([this.message]);
}

class ClosedInstance implements Exception {
  final String message;
  ClosedInstance([this.message]);
}

class TranscriptExists implements Exception {
  final String message;
  TranscriptExists([this.message]);
}
