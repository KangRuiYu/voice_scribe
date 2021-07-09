import 'package:flutter/services.dart';
import 'package:vosk_dart/vosk_exceptions.dart';

/// Creates a new Vosk instance on the native side and connections to it.
///
/// Provides the ability to send method calls and receive events.
class Bridge {
  static const MethodChannel _mainMethodChannel =
      const MethodChannel('vosk_main');

  /// Incremented on each instance to use to make unique channels.
  static int _idCount = 0;

  static const _baseMethodChannelName = 'vosk_method_';
  static const _baseEventChannelName = 'vosk_event_';

  int _id;

  bool _closed = false;

  MethodChannel _methodChannel;
  EventChannel _eventChannel;

  /// Asks for a new instance, while creating method and event channels for it.
  Bridge() {
    _id = _idCount++;
    _mainMethodChannel.invokeMethod('createNewInstance', _id);
    _methodChannel = MethodChannel(_baseMethodChannelName + _id.toString());
    _eventChannel = EventChannel(_baseEventChannelName + _id.toString());
  }

  /// Calls the method on the connected instance.
  ///
  /// If bridge has been closed, [ClosedInstance] will be thrown.
  Future<dynamic> call(String method, [dynamic arguments]) {
    if (_closed) throw ClosedInstance();
    return _methodChannel.invokeMethod(method, arguments);
  }

  /// Returns a broadcast stream for the event channel.
  ///
  /// If bridge has been closed, [ClosedInstance] will be thrown.
  Stream<dynamic> get eventStream {
    if (_closed) throw ClosedInstance();
    return _eventChannel.receiveBroadcastStream();
  }

  /// Closes method and event channels while asking for instance to be removed.
  ///
  /// The resources on the instance are not freed, those most be explicitly
  /// called. If already closed, nothing happens.
  Future<void> close() {
    if (_closed) return null;
    _closed = true;
    return _mainMethodChannel.invokeMethod('removeInstance', _id);
  }
}
