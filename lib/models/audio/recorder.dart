import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:logger/logger.dart' as logger;
import 'package:permission_handler/permission_handler.dart';

import 'package:voice_scribe/constants/audio_constants.dart' as audio_constants;
import 'package:voice_scribe/exceptions/recorder_exceptions.dart';
import 'package:voice_scribe/models/audio/wav_writer.dart';

class Recorder extends ChangeNotifier {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder(
    logLevel: logger.Level.info,
  );
  StreamSubscription<RecordingDisposition> _internalSub;
  StreamController<FoodData> _audioData;
  WavWriter _wavWriter;

  // States
  Stream<RecordingDisposition> get onProgress => _recorder.onProgress;
  Stream<Food> get audioStream => _audioData.stream;
  bool get recording => _recorder.isRecording;
  bool get paused => _recorder.isPaused;
  bool get stopped => _recorder.isStopped;
  bool get active => recording || paused;
  bool opened = false;
  RecordingDisposition
      currentProgress; // To be able to get the current duration

  Future<void> initialize() async {
    // Must initialize the Recorder before using
    if (!await _hasMicrophonePermission()) {
      _askForMicrophonePermission();
    }
    if (opened) throw RecorderAlreadyInitializedException();

    await _recorder.openAudioSession();
    opened = true;
    _initializeStream();
  }

  Future<void> close() async {
    // Must close the Recorder when finished
    if (!opened) throw RecorderAlreadyClosedException();
    await _closeStream();
    opened = false;
    await _recorder.closeAudioSession();
  }

  Future<void> startRecording(String tempLocation) async {
    // Starts the recording process
    if (!opened) {
      throw RecorderNotInitializedException(
        'Attempted to start recorder without initializing it',
      );
    }
    if (active) await terminate(); // Stop recorder if currently recording

    // Create new recording file
    _wavWriter = WavWriter(
      outputPath: tempLocation,
      audioStream: _audioData.stream,
      sampleRate: audio_constants.sample_rate,
    );

    await _recorder.setSubscriptionDuration(Duration(milliseconds: 100));

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      toStream: _audioData.sink,
      sampleRate: audio_constants.sample_rate,
      bitRate: audio_constants.bit_rate,
    );

    notifyListeners();
  }

  Future<Duration> stopRecording(String saveLocation) async {
    // Stops the recording process and returns the resulting file as a Recording
    if (!opened)
      throw RecorderNotInitializedException(
        'Attempted to stop a recorder that is not initialized',
      );
    if (stopped) throw RecorderAlreadyStopped();

    await _recorder.stopRecorder();

    // Close and finalize output file
    File audioFile = await _wavWriter.close();
    await audioFile.rename(saveLocation);
    _wavWriter = null;

    notifyListeners();

    return currentProgress.duration;
  }

  Future<void> terminate() async {
    // Stops any ongoing recording and clean up any files left over
    // Note: Must still close the recorder after
    await _recorder.stopRecorder();

    File leftOverFile = await _wavWriter.close();

    leftOverFile.delete();
    _wavWriter = null;
  }

  Future<void> pauseRecording() async {
    // Pause recording process
    if (!opened)
      throw RecorderNotInitializedException(
        'Attempted to pause a recorder that is not initialized',
      );
    if (paused || stopped) return;

    await _recorder.pauseRecorder();
    notifyListeners();
  }

  Future<void> resumeRecording() async {
    // Resume recording process
    if (!opened)
      throw RecorderNotInitializedException(
        'Attempted to resume a recorder that is not initialized',
      );
    if (recording || stopped) return;

    await _recorder.resumeRecorder();
    notifyListeners();
  }

  void _initializeStream() {
    // Initialize internal streams
    _audioData = StreamController<FoodData>.broadcast();

    _internalSub = _recorder.onProgress.listen(
      (RecordingDisposition newProgress) {
        currentProgress = newProgress;
      },
    );
  }

  Future<void> _closeStream() async {
    // Close stream
    await _internalSub.cancel();
    await _audioData.close();
  }

  Future<void> _askForMicrophonePermission() async {
    // Asks the user for microphone permissions
    await Permission.microphone.request();
  }

  Future<bool> _hasMicrophonePermission() async {
    // Returns True if microphone permissions have been granted
    var status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }
}
