class ThreadAlreadyAllocated implements Exception {
  static const String _message =
      'Attempted to a thread when one already exists.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class ModelAlreadyOpened implements Exception {
  static const String _message =
      'Attempted to open a model when one already exists.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class NonExistentModel implements Exception {
  static const String _message = 'Attempted to use a non-existent model.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class NoOpenThread implements Exception {
  static const String _message =
      'Attempted to perform action when no thread is opened.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class NoOpenModel implements Exception {
  static const String _message =
      'Attempted to perform transcription when no model is open.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class NonExistentWavFile implements Exception {
  static const String _message =
      'Attempted to transcribe non-existent wav file.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class ClosedInstance implements Exception {
  static const String _message = 'Attempted to use a closed Vosk instance.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}
