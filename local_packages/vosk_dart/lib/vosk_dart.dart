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
  bool get modelOpened => _modelOpened;

  /// Returns a broadcast stream of the current transcription progress.
  ///
  /// All transcription jobs will share the same stream. Progress for each file
  /// ranges from 0.0 to 1.0. 0 marks a new transcription and 1 marks the end
  /// of the current one.
  Stream<dynamic> get progressStream => _bridge.eventStream;

  /// Allocates a single thread.
  ///
  /// Throws [ThreadAlreadyAllocated] if there is an existing thread.
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

  /// Attempts to interrupt and close the existing thread.
  ///
  /// If no thread exists, nothing happens.
  Future<void> terminateThread() async {
    if (!_threadAllocated) return null;
    await _bridge.call('terminateThread');
    _threadAllocated = false;
  }

  /// Ask open thread to open the model at the given [modelPath].
  ///
  /// The completion of this function o nly means the task has been queued, not
  /// necessarily that the model has been opened.
  /// Throws a [NoOpenThread] exception when called when no thread is open.
  /// Throws a [ModelAlreadyOpened] exception when a model already exists.
  /// Throws a [NonExistentModel] exception if [modelPath] does not point to an
  /// existing model.
  Future<void> queueModelToBeOpened(String modelPath) async {
    if (!_threadAllocated) throw NoOpenThread();
    if (_modelOpened) throw ModelAlreadyOpened();
    if (!Directory(modelPath).existsSync()) throw NonExistentModel();
    await _bridge.call('queueModelToBeOpened', modelPath);
    _modelOpened = true;
  }

  /// Closes the currently opened model.
  ///
  /// The completion of this function only means the task has been queued, not
  /// necessarily that the model has been opened.
  /// Throws a [NoOpenThread] exception when called when no thread is open.
  /// If no model is opened, nothing happens.
  Future<void> queueModelToBeClosed() async {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_modelOpened) return null;
    await _bridge.call('queueModelToBeClosed');
    _modelOpened = false;
  }

  /// Puts the file at the given [filePath] on queue for transcription
  /// outputting the result at the given [resultPath].
  ///
  /// Only one file will be transcribing at a given time.
  /// The completion of this function only means the task has been queued, not
  /// necessarily that the file has finished transcribing.
  /// Throws a [NoOpenThread] exception when called when no thread is open.
  /// Throws a [NoOpenModel] exception when no model is currently opened.
  /// Throws a [NonExistentWavFile] if the given [filePath] points to a
  /// non-existent file.
  /// Throws a [TranscriptExists] if the given [transcriptPath] points
  /// to a file that already exists.
  Future<void> queueFileForTranscription(
    String filePath,
    String transcriptPath,
  ) {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_modelOpened) throw NoOpenModel();
    if (!File(filePath).existsSync()) throw NonExistentWavFile();
    if (File(transcriptPath).existsSync()) throw TranscriptExists();

    return _bridge.call(
      'queueFileForTranscription',
      {
        'filePath': filePath,
        'transcriptPath': transcriptPath,
        'sampleRate': 16000,
      },
    );
  }

  /// Closes resources and any associated connections.
  ///
  /// Once called, this instance is unusable. Any attempt will result in a
  /// [ClosedInstance] thrown by the bridge.
  /// If already closed, nothing happens.
  /// Can optionally be forcefully closed, where any ongoing transcription
  /// process will halted.
  Future<void> close({bool force = false}) async {
    if (force) {
      await _bridge.call('forceClose');
    } else {
      await _bridge.call('close');
    }
    await _bridge.close();
    _modelOpened = false;
    _threadAllocated = false;
  }
}
