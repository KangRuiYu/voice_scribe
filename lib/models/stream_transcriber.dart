import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:vosk_dart/transcript_event.dart';
import 'package:vosk_dart/vosk_dart.dart';

import '../exceptions/transcriber_exceptions.dart';
import 'future_initializer.dart';
import '../utils/model_manager.dart' as modelManager;

/// Used to transcribe the audio data coming from a stream.
///
/// Can listen to ongoing transcript progress using the provided [eventStream].
class StreamTranscriber with FutureInitializer<StreamTranscriber> {
  /// Used by the [_internalBuffer] to determine when to feed data to Vosk.
  static const buffer_threshold = 8000;

  /// True if transcriber is currently transcribing a file.
  bool get active => _transcript.path.isNotEmpty;

  /// Stream of [TranscriptEvents] from the ongoing transcription.
  ///
  /// Will only show events where the transcript path of the event matches that
  /// of [_transcript]'s path to prevent events from previous instances from
  /// leaking over.
  Stream<TranscriptEvent> get eventStream => _voskInstance.eventStream.where(
        (TranscriptEvent event) => event.transcriptPath == _transcript.path,
      );

  /// Internal Vosk instance that does the heavy work.
  final VoskInstance _voskInstance = VoskInstance();

  /// The subscription to audio data that is fed to Vosk.
  StreamSubscription<Food> _audioSub;

  BytesBuilder _internalBuffer = BytesBuilder();

  File _transcript = File('');

  /// Starts a new [_transcript] file.
  ///
  /// If there is a transcript in progress, then nothing happens.
  Future<void> start({
    @required Stream<Food> audioStream,
    @required String tempLocation,
  }) async {
    assertReady();
    if (active) return;

    _transcript = File(tempLocation);
    await _voskInstance.startNewTranscript(_transcript.path);

    _audioSub = audioStream.listen(_onAudioData);
  }

  /// Stops transcribing the current transcript and the transcript is deleted.
  ///
  /// If no transcript is in progress, a [NoTranscriptStarted] exception is
  /// thrown.
  Future<void> stop() async {
    assertReady();
    if (!active) throw NoTranscriptStarted();

    await _audioSub.cancel();

    await _voskInstance.terminateTranscript();

    await _transcript.delete();
    _transcript = File('');

    _internalBuffer.clear();
  }

  /// Finishes and saves the [_transcript] to the given file location.
  ///
  /// If there is no transcript in progress, a [NoTranscriptStarted] exception
  /// is thrown.
  /// Will overwrite any existing files.
  /// Future completes with exception if a directory exists at the location.
  Future<File> finish(String saveLocation) async {
    assertReady();
    if (!active) throw NoTranscriptStarted();

    await _audioSub.cancel();

    await _voskInstance.feedBuffer(
      _internalBuffer.takeBytes(),
    ); // Feed any remaining data.
    await _voskInstance.finishTranscript();

    File finalTranscript = await _transcript.rename(saveLocation);
    _transcript = File('');

    return finalTranscript;
  }

  @override
  @protected
  Future<StreamTranscriber> onInitialize(Map<String, dynamic> args) async {
    await _voskInstance.allocateSingleThread();

    String modelPath = await modelManager.firstAvailableModel();
    if (modelPath == null) throw NoAvailableModel();
    await _voskInstance.openModel(modelPath);

    return this;
  }

  @override
  @protected
  Future<void> onTerminate() async {
    if (active) await stop();
    await _voskInstance.closeResources();
    await _voskInstance.disconnect();
  }

  /// Called on new audio data coming from [_audioStream].
  ///
  /// Buffers incoming data until the size of the buffer meets or exceeds the
  /// threshold in which it will then feed it into Vosk.
  void _onAudioData(Food food) {
    if (food is FoodData) {
      _internalBuffer.add(food.data);
      if (_internalBuffer.length >= buffer_threshold) {
        _voskInstance.feedBuffer(_internalBuffer.takeBytes());
      }
    }
  }
}

class NoTranscriptStarted implements Exception {
  final String message;
  NoTranscriptStarted([this.message]);
}
