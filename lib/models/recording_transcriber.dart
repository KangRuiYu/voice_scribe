import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:voice_scribe/exceptions/transcriber_exceptions.dart';
import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/utils/file_utils.dart';
import 'package:voice_scribe/utils/model_manager.dart' as modelManager;
import 'package:vosk_dart/vosk_dart.dart';

/// Different states for a recording in [RecordingTranscriber].
enum RecordingState { processing, queued, notQueued }

/// Transcribes an indefinite number of recordings, one at a time.
///
/// Can be used in conjunction with a provider to be updated on when a recording
/// has finished. To listen to individual recording progress,
/// you can listen to the provided progress stream.
///
/// Note: Should not instantiate more than one at a time.
class RecordingTranscriber extends ChangeNotifier {
  /// Transcription progress for the current recording.
  Stream<dynamic> get progressStream => _voskInstance.progressStream;

  /// Vosk instance that does the transcribing.
  final VoskInstance _voskInstance = VoskInstance();

  /// Recordings that will be transcribed.
  final Queue<Recording> _queue = Queue<Recording>();

  // Current recording being transcribed.
  Recording _currentRecording;
  Recording get currentRecording => _currentRecording;

  // Current transcription file being written to.
  File _currentTranscriptionFile;

  /// Internal subscription to transcription progress.
  ///
  /// It is used to detect when certain transcriptions are done, so the proper
  /// state can be updated.
  StreamSubscription<dynamic> _progressSub;

  RecordingTranscriber() {
    _progressSub = _voskInstance.progressStream.listen(_onProgress);
  }

  /// Closes resources and closes this transcriber permanently.
  ///
  /// It is usually called by a provider, and once called, is useless.
  /// Closes threads and models if they exist.
  /// Stops subscriptions to progress streams.
  /// Closes the underlying vosk instance.
  @override
  void dispose() {
    _progressSub.cancel();
    _voskInstance.close();
    super.dispose();
  }

  /// Puts [recording] at end of queue. If it is the only recording, start
  /// transcribing it.
  void addToQueue(Recording recording) {
    _queue.add(recording);
    if (_currentRecording == null) {
      _transcribeNext();
    }
    notifyListeners();
  }

  /// Remove [recording] from queue or cancel if it is being transcribed.
  ///
  /// If the recording does not exist, nothing happens.
  void cancel(Recording recording) async {
    if (_currentRecording == recording) {
      await _voskInstance.terminateThread();
      _transcribeNext();
    } else {
      _queue.remove(recording);
    }
    notifyListeners();
  }

  /// Returns the current state of the [recording].
  RecordingState progressOf(Recording recording) {
    if (_currentRecording == recording) {
      return RecordingState.processing;
    } else if (_queue.contains(recording)) {
      return RecordingState.queued;
    } else {
      return RecordingState.notQueued;
    }
  }

  /// Start transcribing the next recording in [_queue].
  ///
  /// If there is no recordings in [_queue], [_currentRecording] is instead set
  /// to null.
  /// Calls [_allocateResources] if it is the first call.
  /// Throws a [NonExistentWavFile] exception if the next recording in
  /// queue does not exist.
  /// Throws a [TranscriptionAlreadyExists] exception if the recording already
  /// has a transcription file.
  Future<void> _transcribeNext() async {
    if (_queue.isEmpty) {
      _currentRecording = null;
      return;
    }

    _currentRecording = _queue.removeFirst();
    _currentTranscriptionFile =
        await generateTranscriptionFile(_currentRecording.name);

    await _readyResources();

    await _voskInstance.queueFileForTranscription(
      _currentRecording.audioPath,
      _currentTranscriptionFile.path,
    );
  }

  /// Allocates any resources if needed, such as threads or models.
  ///
  /// If a model is needed and none could be found, throws a [NoAvailableModel]
  /// exception.
  Future<void> _readyResources() async {
    if (!_voskInstance.threadAllocated) {
      await _voskInstance.allocateSingleThread();
    }
    if (!_voskInstance.modelOpened) {
      String modelPath = await modelManager.firstAvailableModel();
      if (modelPath == null) throw NoAvailableModel();
      await _voskInstance.queueModelToBeOpened(modelPath);
    }
  }

  /// Called on progress event.
  ///
  /// When a recording is done, the
  /// the next recording from [_queue] is transcribed
  /// and any listeners will be notified.
  void _onProgress(dynamic progress) async {
    if (progress == 1.0) {
      _currentRecording.transcriptionPath = _currentTranscriptionFile.path;
      await RecordingsManager.updateImportFile(_currentRecording);
      await _transcribeNext();
      notifyListeners();
    }
  }
}
