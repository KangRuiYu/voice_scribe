import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:vosk_dart/transcript_event.dart';
import 'package:vosk_dart/vosk_dart.dart';

import 'package:voice_scribe/constants/audio_constants.dart' as audio_constants;
import 'package:voice_scribe/exceptions/transcriber_exceptions.dart';
import 'package:voice_scribe/models/audio/recording.dart';
import 'package:voice_scribe/utils/model_utils.dart' as model_utils;

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
  Stream<TranscriptEvent> get progressStream => _voskInstance.eventStream;

  // Current recording being transcribed.
  Recording get currentRecording => _currentRecording;
  Recording _currentRecording;

  /// Vosk instance that does the transcribing.
  final VoskInstance _voskInstance = VoskInstance();

  /// Will be used to search for the first available transcription model to use.
  final Directory _modelDirectory;

  /// Recordings that will be transcribed.
  final Queue<Recording> _queue = Queue<Recording>();

  /// Internal subscription to transcription progress.
  ///
  /// It is used to detect when certain transcriptions are done, so the proper
  /// state can be updated.
  StreamSubscription<dynamic> _progressSub;

  RecordingTranscriber(this._modelDirectory) {
    _progressSub = _voskInstance.eventStream.listen(_onProgress);
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
    _voskInstance.closeResources();
    _voskInstance.disconnect();
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
  /// If canceled, then the current transcription file is deleted.
  /// If the recording does not exist, nothing happens.
  void cancel(Recording recording) async {
    if (_currentRecording == recording) {
      await _voskInstance.terminateThread();
      await _readyResources();
      await _voskInstance.terminateTranscript();
      await _currentRecording.transcriptFile.delete();
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

    await _readyResources();

    await _voskInstance.startNewTranscript(
      _currentRecording.transcriptFile.path,
      audio_constants.sample_rate,
    );
    await _voskInstance.feedFile(_currentRecording.audioFile.path);
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
      String modelPath = await model_utils.firstModelIn(_modelDirectory);
      if (modelPath.isEmpty) throw NoAvailableModel();
      await _voskInstance.openModel(modelPath);
    }
  }

  /// Called on progress event.
  ///
  /// When a recording is done, the
  /// the next recording from [_queue] is transcribed
  /// and any listeners will be notified.
  void _onProgress(TranscriptEvent event) async {
    if (event.progress == 1.0) {
      await _voskInstance.finishTranscript(post: false);
      await _transcribeNext();
      notifyListeners();
    }
  }
}
