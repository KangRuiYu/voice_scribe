import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:voice_scribe/models/recording.dart';

class RecorderAlreadyInitializedException implements Exception {
  static const String _message =
      'Attempted to initialize an already initialized Recorder.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class RecorderAlreadyClosedException implements Exception {
  static const String _message = 'Attempted to close a non-open Recorder';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class RecorderNotInitializedException implements Exception {
  final String _message;
  RecorderNotInitializedException(this._message);

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class RecorderAlreadyStopped implements Exception {
  static const String _message =
      'Attempted to stop an already stopped recorder';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class Recorder extends ChangeNotifier {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  File _outputFile;
  StreamSubscription<RecordingDisposition> _internalSub;

  // States
  Stream<RecordingDisposition> get onProgress => _recorder.onProgress;
  bool get recording => _recorder.isRecording;
  bool get paused => _recorder.isPaused;
  bool get stopped => _recorder.isStopped;
  bool get active => recording || paused;
  bool opened = false;
  RecordingDisposition
      currentProgress; // To be able to get the current duration
  File get outputFile => _outputFile;

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

  Future<void> startRecording() async {
    // Starts the recording process
    if (!opened) {
      throw RecorderNotInitializedException(
        'Attempted to start recorder without initializing it',
      );
    }
    if (active) await terminate(); // Stop recorder if currently recording

    var dir = await getExternalStorageDirectory();
    var recordingName = _generateName();
    String outputFilePath = path.join(dir.path, '$recordingName.aac');
    _outputFile = File(outputFilePath);
    print(_outputFile.path);

    await _recorder.startRecorder(
      codec: Codec.aacADTS,
      toFile: _outputFile.path,
      sampleRate: 44100,
      bitRate: 64000,
    );

    notifyListeners();
  }

  Future<Recording> stopRecording([String recordingName]) async {
    // Stops the recording process and returns the resulting file as a Recording
    if (!opened)
      throw RecorderNotInitializedException(
        'Attempted to stop a recorder that is not initialized',
      );
    if (stopped) throw RecorderAlreadyStopped();

    await _recorder.stopRecorder();

    if (recordingName.isNotEmpty) {
      recordingName += '.aac';
      Directory parentDir = _outputFile.parent;
      String newPath = path.join(parentDir.path, recordingName);
      _outputFile = _outputFile.renameSync(newPath);
    }

    Recording recording = Recording(
      file: _outputFile,
      duration: currentProgress.duration,
    );
    _outputFile = null;

    notifyListeners();

    return recording;
  }

  Future<void> terminate() async {
    // Stops any ongoing recording and clean up any files left over
    // Note: Must still close the recorder after
    await _recorder.stopRecorder();
    _outputFile.delete();
    _outputFile = null;
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
    // Initialize internal stream
    _internalSub = _recorder.onProgress.listen(
      (RecordingDisposition newProgress) {
        currentProgress = newProgress;
      },
    );
  }

  Future<void> _closeStream() async {
    // Close stream
    await _internalSub.cancel();
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

  String _generateName() {
    // Generates a unique name based on the current time (down to the second)
    DateTime date = DateTime.now();
    return '${date.month}-${date.day}-${date.year}-${date.hour}-${date.minute}-${date.second}';
  }
}
