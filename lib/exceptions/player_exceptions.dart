/*
A collection of exceptions thrown by the player.
 */

class PlayerAlreadyInitializedException implements Exception {
  static const String _message =
      'Attempted to initialize an already initialized Player.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class PlayerAlreadyClosedException implements Exception {
  static const String _message = 'Attempted to close a non-open Player';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class PlayerNotInitializedException implements Exception {
  final String _message;
  PlayerNotInitializedException(this._message);

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}
