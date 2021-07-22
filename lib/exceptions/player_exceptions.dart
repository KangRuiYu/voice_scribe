/*
A collection of exceptions thrown by the player.
 */

class PlayerAlreadyInitializedException implements Exception {
  final String message;
  PlayerAlreadyInitializedException([this.message]);
}

class PlayerAlreadyClosedException implements Exception {
  final String message;
  PlayerAlreadyClosedException([this.message]);
}

class PlayerNotInitializedException implements Exception {
  final String message;
  PlayerNotInitializedException([this.message]);
}
