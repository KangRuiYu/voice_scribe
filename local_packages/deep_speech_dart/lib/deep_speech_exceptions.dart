class ModelDoesNotExist implements Exception {
  static const String _message =
      "Attempted to use a deep speech model that doesn't exist.";

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class ScorerDoesNotExist implements Exception {
  static const String _message =
      "Attempted to use a scorer that doesn't exist.";

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class InvalidByteBuffer implements Exception {
  static const String _message = 'Byte buffer must be of even length.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class NegativeResults implements Exception {
  static const String _message = 'Cannot have negative results.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}
