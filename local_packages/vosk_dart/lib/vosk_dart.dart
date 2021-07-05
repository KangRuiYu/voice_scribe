import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:vosk_dart/vosk_exceptions.dart';

/*
Bindings to the native Vosk implementation. Provides the basic functions.
 */
class Vosk {
  static const MethodChannel _methodChannel =
      const MethodChannel('vosk_method');
  static const EventChannel _eventChannel = const EventChannel('vosk_stream');

  static Future<String> get platformVersion async {
    final String version =
        await _methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  static bool _threadAllocated = false;
  static bool get threadAllocated => _threadAllocated;

  static bool _modelOpened = false;
  static bool get opened => _modelOpened;

  // Allocates a single thread for use. If a thread already exists, an exception
  // is thrown.
  static Future<void> allocateSingleThread() {
    if (_threadAllocated) throw ThreadAlreadyAllocated();
    _methodChannel.invokeMethod('allocateSingleThread');
    _threadAllocated = true;
    return null;
  }

  // Deallocate the existing thread. If no thread exists, nothing happens.
  static Future<void> deallocateThread() {
    if (!_threadAllocated) return null;
    _methodChannel.invokeMethod('deallocateThread');
    _threadAllocated = false;
    return null;
  }

  // Ask open thread to open the given model. If model is already opened, the
  // given model path doesn't exist or no thread is opened, an exception is
  // thrown. The completion of this function only means the task has been
  // queued, not necessarily that the model has been opened.
  static Future<void> queueModelToBeOpened(String modelPath) {
    if (!_threadAllocated) throw NoOpenThread();
    if (_modelOpened) throw ModelAlreadyOpened();
    if (!Directory(modelPath).existsSync()) throw NonExistentModel();
    _methodChannel.invokeMethod('queueModelToBeOpened', modelPath);
    _modelOpened = true;
    return null;
  }

  // Closes the currently opened model. If no model is opened, nothing happens.
  // If no thread is open, an exception is thrown. The completion of this
  // function only means the task has been queued, not necessarily that the
  // model has been opened.
  static Future<void> queueModelToBeClosed() {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_modelOpened) return null;
    _methodChannel.invokeMethod('queueModelToBeClosed');
    _modelOpened = false;
    return null;
  }

  // Puts the given file on queue for transcription. Only one file will be
  // transcribing at a given time. Throws an exception if the given file does
  // not exist, no model is opened, or no thread is open. The completion of this
  // function only means the task has been queued, not necessarily that the
  // model has opened.
  static Future<void> queueFileForTranscription(String filePath) {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_modelOpened) throw NoOpenModel();
    if (!File(filePath).existsSync()) throw NonExistentWavFile();
    return _methodChannel.invokeMethod(
      'queueFileForTranscription',
      {'filePath': filePath, 'sampleRate': 16000},
    );
  }

  // Cleans any existing resources (thread and model) currently being used. If
  // no thread is currently opened, an exception is thrown, as without a thread,
  // the model cannot be deallocated.
  static Future<void> clean() {
    if (!_threadAllocated) throw NoOpenThread();
    return _methodChannel.invokeMethod('clean');
  }

  // Returns a broadcast stream of the current transcription progress. All
  // transcription jobs will share the same stream. Progress for each file
  // ranges from 0.0 to 1.0. 0 marks a new transcription and 1 marks the end
  // of the current one.
  static Stream<dynamic> getProgressStream() {
    return _eventChannel.receiveBroadcastStream();
  }
}
