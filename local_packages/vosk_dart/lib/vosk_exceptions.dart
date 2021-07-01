class NonExistentModel implements Exception {
  static const String _message = 'Attempted to use a non-existent model.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class NonPositiveSampleRate implements Exception {
  static const String _message = 'Given non-positive sample rate.';

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
