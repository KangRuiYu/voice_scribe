import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:vosk_dart/vosk_exceptions.dart';

class FileTranscriber {
  static const MethodChannel _channel = const MethodChannel('vosk_dart');
  static const EventChannel _eventChannel = const EventChannel('vosk_stream');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static int _queuedTasks = 0; // The number of queued transcriptions.
  static int get queuedTasks => _queuedTasks;

  static bool _opened = false;
  static bool get opened => _opened;

  // Asks a separate thread to initialize transcription resources.
  // If transcriber already opened, nothing happens.
  // (Note: This function only asks for the transcriber to be opened. It's
  //  completion does not indicate that the opening process has finished.
  //  However, it is safe to queue files when this functions has finished, as
  //  transcriptions will automatically wait for resources to be loaded.)
  static Future<void> queueModelToBeOpened(String modelPath) {
    if (!Directory(modelPath).existsSync()) throw NonExistentModel();
    if (_opened) return null;
    _channel.invokeMethod('queueModelToBeOpened', modelPath);
    _opened = true;
    return null;
  }

  // Puts the given file on queue for transcription. Only one file will be
  // transcribing at a given time.
  static Future<void> queueFileForTranscription(String filePath) {
    if (!File(filePath).existsSync()) throw NonExistentWavFile();
    return _channel.invokeMethod(
      'queueFileForTranscription',
      {'filePath': filePath, 'sampleRate': 16000},
    );
  }

  // Returns a broadcast stream of the current transcription progress.
  static Stream<dynamic> getProgressStream() {
    return _eventChannel.receiveBroadcastStream();
  }

  // Frees resources used for transcribing. If transcriber is already closed
  // nothing happens.
  // (Note: This function only asks for the transcriber to close. It's
  //  completion does not indicate that it has fully closed. However, it is safe
  //  to call open() if close has finished, as open() will open an entirely new
  //  thread.)
  static Future<void> queueModelToBeClosed() {
    if (!_opened) return null;
    _channel.invokeMethod('queueModelToBeClosed');
    _opened = false;
    return null;
  }
}
