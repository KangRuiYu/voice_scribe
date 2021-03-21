import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:voice_scribe/models/recording.dart';

class Recorder extends ChangeNotifier {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  File _outputFile;
  StreamSubscription _progressSubscription;

  bool get recording => _recorder.isRecording;
  bool get paused => _recorder.isPaused;
  RecordingDisposition
      currentProgress; // To be able to get the current duration
  File get outputFile => _outputFile;

  Future<void> startRecording() async {
    // Starts the recording process
    await _openAudioSession();

    if (!await _hasMicrophonePermission()) {
      _askForMicrophonePermission();
    }

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

    _listenToStream();

    notifyListeners();
  }

  Future<Recording> stopRecording([String recordingName]) async {
    // Stops the recording process and returns the resulting file as a Recording
    await _closeStream();
    await _recorder.stopRecorder();
    _closeAudioSession();

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
    await _closeStream();
    await _recorder.stopRecorder();
    _closeAudioSession();
    _outputFile.delete();
    _outputFile = null;
  }

  Future<void> pauseRecording() async {
    // Pause recording process
    await _recorder.pauseRecorder();
    notifyListeners();
  }

  Future<void> resumeRecording() async {
    // Resume recording process
    await _recorder.resumeRecorder();
    notifyListeners();
  }

  Future<void> _openAudioSession() async {
    // Audio session must be opened before recording can start
    await _recorder.openAudioSession();
  }

  Stream<RecordingDisposition> progressInfo() async* {
    // Returns a safe progress stream, one that will produce values even when
    // the recorder is not ready.
    RecordingDisposition latestProgress = RecordingDisposition.zero();
    StreamSubscription<RecordingDisposition> internalSub =
        _recorder.onProgress.listen((RecordingDisposition newProgress) {
      latestProgress = newProgress;
    });

    try {
      while (true) {
        await Future.delayed(Duration(milliseconds: 100));
        yield latestProgress;
      }
    } finally {
      internalSub.cancel();
    }
  }

  Future<void> _closeAudioSession() async {
    await _recorder.closeAudioSession();
  }

  void _listenToStream() {
    // Begins listening to progress stream
    _progressSubscription =
        progressInfo().listen((RecordingDisposition newProgress) {
      currentProgress = newProgress;
    });
  }

  Future<void> _closeStream() async {
    // Stops listening to the stream
    await _progressSubscription.cancel();
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
