import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:vosk_dart/bridge.dart';
import 'package:vosk_dart/transcript_event.dart';
import 'package:vosk_dart/vosk_exceptions.dart';

/// Bindings to a native Vosk instance, providing basic functions.
class VoskInstance {
  /// Used to communicate with native code.
  final Bridge _bridge = Bridge();

  bool get threadAllocated => _threadAllocated;
  bool _threadAllocated = false;

  bool get modelOpened => _modelOpened;
  bool _modelOpened = false;

  bool get transcriptInProgress => _transcriptInProgress;
  bool _transcriptInProgress = false;

  /// Broadcast stream of ongoing transcription events.
  Stream<TranscriptEvent> get eventStream =>
      _bridge.eventStream.map((event) => TranscriptEvent(event));

  /// Allocates a single thread.
  ///
  /// Will wait for any previous thread to finish before new tasks are executed.
  /// Throws [ThreadAlreadyAllocated] if there is an existing thread.
  Future<void> allocateSingleThread() async {
    if (_threadAllocated) throw ThreadAlreadyAllocated();
    await _bridge.call('allocateSingleThread');
    _threadAllocated = true;
  }

  /// Deallocate the existing thread.
  ///
  /// If no thread exists, nothing happens.
  /// Thread will not accept any new tasks and will wait for existing ones to
  /// finish before closing.
  Future<void> deallocateThread() async {
    if (!_threadAllocated) return null;
    await _bridge.call('deallocateThread');
    _threadAllocated = false;
  }

  /// Attempts to interrupt and close the existing thread.
  ///
  /// If no thread exists, nothing happens.
  /// There is no guarantee that the thread will terminate at request.
  Future<void> terminateThread() async {
    if (!_threadAllocated) return null;
    await _bridge.call('terminateThread');
    _threadAllocated = false;
  }

  /// Ask open thread to open the model at the given [modelPath].
  ///
  /// Throws a [NoOpenThread] exception when called when no thread is open.
  /// Throws a [ModelAlreadyOpened] exception when a model already exists.
  /// Throws a [NonExistentModel] exception if [modelPath] does not point to an
  /// existing model.
  Future<void> openModel(String modelPath) async {
    if (!_threadAllocated) throw NoOpenThread();
    if (_modelOpened) throw ModelAlreadyOpened();
    if (!Directory(modelPath).existsSync()) throw NonExistentModel();
    await _bridge.call('openModel', modelPath);
    _modelOpened = true;
  }

  /// Closes the currently opened model.
  ///
  /// Throws a [NoOpenThread] exception when called when no thread is open.
  /// If no model is opened, nothing happens.
  Future<void> closeModel() async {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_modelOpened) return null;
    await _bridge.call('closeModel');
    _modelOpened = false;
  }

  /// Starts a new transcript file.
  ///
  /// Subsequent calls to feed files will write output to [transcriptPath].
  /// Throws a [NoOpenThread] exception when called when no thread is open.
  /// Throws a [NoOpenModel] exception when no model is currently opened.
  /// Throws a [TranscriptExists] if the given [transcriptPath] points
  /// to a file that already exists.
  /// Throws a [TranscriptInProgress] exception when called when a transcript
  /// is currently being processed.
  Future<void> startNewTranscript(String transcriptPath) async {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_modelOpened) throw NoOpenModel();
    if (File(transcriptPath).existsSync()) throw TranscriptExists();
    if (_transcriptInProgress) throw TranscriptInProgress();

    await _bridge.call(
      'startNewTranscript',
      {
        'transcriptPath': transcriptPath,
        'sampleRate': 16000,
      },
    );

    _transcriptInProgress = true;
  }

  /// Forcefully closes current transcript file.
  ///
  /// The transcript file is not deleted.
  /// If there is no transcript in progress, nothing happens.
  /// Throws a [NoOpenThread] exception when called when no thread is open.
  Future<void> terminateTranscript() async {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_transcriptInProgress) return;

    await _bridge.call('terminateTranscript');

    _transcriptInProgress = false;
  }

  /// Writes final results to transcript file and closes.
  ///
  /// If [post] is true (default), then the final events will be posted to the
  /// event stream. Otherwise, no events are posted.
  /// If there is no transcript in progress, nothing happens.
  /// Throws a [NoOpenThread] exception when called when no thread is open.
  Future<void> finishTranscript({bool post = true}) async {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_transcriptInProgress) return;

    await _bridge.call('finishTranscript', post);

    _transcriptInProgress = false;
  }

  /// Feeds the audio data at [filePath] to the current transcript file.
  ///
  /// If [post] is true (default), then the associated events will be posted to
  /// the event stream. Otherwise, no events are posted.
  /// Throws a [NoOpenThread] exception when called when no thread is open.
  /// Throws a [NoTranscriptInProgress] exception when called while no
  /// transcript is being processed.
  /// Throws a [NonExistentWavFile] if the given [filePath] points to a
  /// non-existent file.
  Future<void> feedFile(String filePath, {bool post = true}) {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_transcriptInProgress) throw NoTranscriptInProgress();
    if (!File(filePath).existsSync()) throw NonExistentWavFile();

    return _bridge.call('feedFile', {'filePath': filePath, 'post': post});
  }

  /// Feeds [buffer] to the current transcript file.
  ///
  /// If [post] is true (default), then the associated events will be posted to
  /// the event stream. Otherwise, no events are posted.
  /// Throws a [NoOpenThread] exception when called when no thread is open.
  /// Throws a [NoTranscriptInProgress] exception when called while no
  /// transcript is being processed.
  Future<void> feedBuffer(Uint8List buffer, {bool post = true}) {
    if (!_threadAllocated) throw NoOpenThread();
    if (!_transcriptInProgress) throw NoTranscriptInProgress();

    return _bridge.call('feedBuffer', {'buffer': buffer, 'post': post});
  }

  /// Closes resources and any associated connections.
  ///
  /// If [force] is false (default), will wait for any existing tasks to finish
  /// before resources are closed.
  /// If [force] is true, will attempt to halt any tasks then close resources.
  Future<void> closeResources({bool force = false}) async {
    await _bridge.call('closeResources', force);
    _transcriptInProgress = false;
    _modelOpened = false;
    _threadAllocated = false;
  }

  /// Disconnects this instance from its native code.
  ///
  /// If already disconnected, nothing happens.
  /// Once called, this instance is unusable. Any attempt will result in a
  /// [ClosedInstance] thrown by the bridge.
  Future<void> disconnect() async {
    await _bridge.call('disconnect');
    await _bridge.close();
  }
}
