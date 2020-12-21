import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

class Recorder extends ChangeNotifier {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool get recording => _recorder.isRecording;
  bool get paused => _recorder.isPaused;
  Stream<RecordingDisposition> get progress => _recorder.onProgress;

  File _outputFile;

  void startRecording() async {
    // Starts the recording process
    _openAudioSession();

    if (!await _hasMicrophonePermission()) {
      _askForMicrophonePermission();
    }

    var dir = await getExternalStorageDirectory();
    var recordingName = DateTime.now().toString();
    String outputFilePath = path.join(dir.path, '$recordingName.aac');
    _outputFile = File(outputFilePath);
    print(_outputFile.path);

    await _recorder.startRecorder(
      codec: Codec.aacADTS,
      toFile: _outputFile.path,
    );

    notifyListeners();
  }

  void stopRecording([String recordingName]) async {
    // Stops the recording process
    await _recorder.stopRecorder();
    _closeAudioSession();

    if (recordingName.isNotEmpty) {
      recordingName += '.aac';
      Directory parentDir = _outputFile.parent;
      String newPath = path.join(parentDir.path, recordingName);
      _outputFile.renameSync(newPath);
    }

    _outputFile = null;

    notifyListeners();
  }

  void pauseRecording() async {
    // Pause recording process
    await _recorder.pauseRecorder();
    notifyListeners();
  }

  void resumeRecording() async {
    // Resume recording process
    await _recorder.resumeRecorder();
    notifyListeners();
  }

  void _openAudioSession() async {
    // Audio session must be opened before recording can start
    await _recorder.openAudioSession();
  }

  void _closeAudioSession() async {
    await _recorder.closeAudioSession();
  }

  void _askForMicrophonePermission() async {
    // Asks the user for microphone permissions
    await Permission.microphone.request();
  }

  Future<bool> _hasMicrophonePermission() async {
    // Returns True if microphone permissions have been granted
    var status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }
}
