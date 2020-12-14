import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Recorder extends ChangeNotifier{
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _started = false;
  bool get started => _started;

  void startRecording() async {
    _openAudioSession();

    if (!await _hasMicrophonePermission()) {
      _askForMicrophonePermission();
    }

    var tempDir = await getExternalStorageDirectory();
    print(tempDir);
    String outputFile = tempDir.path + '/flutter_sound-tmp.aac';
    await _recorder.startRecorder(
      codec: Codec.aacADTS,
      toFile: outputFile,
    );

    notifyListeners();
  }

  void stopRecording() async {
    await _recorder.stopRecorder();
    _closeAudioSession();

    notifyListeners();
  }

  void _openAudioSession() async {
    // Audio session must be opened before recording can start
    await _recorder.openAudioSession();
    _started = true;
  }

  void _closeAudioSession() async {
    await _recorder.closeAudioSession();
    _started = false;
  }

  void _askForMicrophonePermission() async {
    await Permission.microphone.request();
  }

  Future<bool> _hasMicrophonePermission() async {
    var status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }
}
