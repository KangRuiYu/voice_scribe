import 'dart:async';
import 'dart:io';

import 'package:vosk_dart/bridge.dart';
import 'package:vosk_dart/vosk_exceptions.dart';

/// Bindings to a native Vosk instance, providing basic functions.
class VoskInstance {
  /// Used to communicate with native code.
  final Bridge _bridge = Bridge();

  bool _threadAllocated = false;
  bool get threadAllocated => _threadAllocated;

  bool _modelOpened = false;
  bool get opened => _modelOpened;

  /// Returns a broadcast stream of the current transcription progress.
  ///
  /// All transcription jobs will share the same stream. Progress for each file
  /// ranges from 0.0 to 1.0. 0 marks a new transcription and 1 marks the end
  /// of the current one.
  Stream<dynamic> get progressStream => _bridge.eventStream;

  /// Allocates a single thread. Exception is thrown if one already exists.
  Future<void> allocateSingleThread() async {
    if (_threadAllocated) throw ThreadAlreadyAllocated();
    await _bridge.call('allocateSingleThread');
    _threadAllocated = true;
  }

  /// Deallocate the existing thread. If no thread exists, nothing happens.
  Future<void> deallocateThread() async {
    if (!_threadAllocated) return null;
    await _bridge.call('deallocateThread');
    _threadAllocated = false;
  }

  /// Ask open thread to open the given model.
  ///
  /// If model is already opened, the given [modelPath] doesn't exist or no
  /// thread is opened, an exception is thrown. The completion of this function
  /// only means the task has been queued, not necessarily that the model has
  /// been opened.
  Future<void> queueModelToBeOpened(String modelPath) async {
    if (!_threadAllocated) throw NoOpenThread();
    if (_modelOpened) throw ModelAlreadyOpened();
    if (!Directory(modelPath).existsSync()) throw NonExistentModel();
    await _bridge.call('queueModelToBeOpened', modelPath);
    _modelOpened = true;
  }

  /// Closes the currently opened model.
  ///
  /// If no model is opened, nothing happens. If no thread is open, an exception
  /// is thrown. The completion of this function only means the task has been
  /// queued, not necessarily that the model has been opened.
  Future<void> queueModelToBeClosed() async {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_modelOpened) return null;
    await _bridge.call('queueModelToBeClosed');
    _modelOpened = false;
  }

  /// Puts the given file on queue for transcription.
  ///
  /// Only one file will be transcribing at a given time. Throws an exception if
  /// the given file does not exist, no model is opened, or no thread is open.
  /// The completion of this function only means the task has been queued, not
  /// necessarily that the model has opened.
  Future<void> queueFileForTranscription(String filePath) {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_modelOpened) throw NoOpenModel();
    if (!File(filePath).existsSync()) throw NonExistentWavFile();
    return _bridge.call(
      'queueFileForTranscription',
      {'filePath': filePath, 'sampleRate': 16000},
    );
  }

  /// Closes resources and any associated connections.
  ///
  /// Once called, this instance is unusable. Any attempt will result in a
  /// [ClosedInstance] thrown by the bridge. If already closed, nothing happens.
  Future<void> close() async {
    await _bridge.call('close');
    await _bridge.close();
    _modelOpened = false;
    _threadAllocated = false;
  }
}
