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

  StreamController<Food> _pcmController; // The pcm stream controller
  StreamSubscription<Food> _pcmSub; // The pcm stream subscription
  File get outputFile => _outputFile; // The final output of the recorder
  IOSink _outputFileSink; // The IOStream that writes to the output file

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
    String outputFilePath = path.join(dir.path, '$recordingName.pcm');
    _outputFile = File(outputFilePath);
    _outputFileSink = _outputFile.openWrite();

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      toStream: _pcmController.sink,
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

    // Close and finalize output file
    await _outputFileSink.flush();
    await _outputFileSink.close();

    // Rename file if a recording name is given
    if (recordingName.isNotEmpty) {
      String newPath = path.join(_outputFile.parent.path, '$recordingName.pcm');
      _outputFile = _outputFile.renameSync(newPath);
    }

    // Convert file
    _outputFile = await _convertPCM(_outputFile);

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

    await _outputFileSink.flush();
    await _outputFileSink.close();

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
    // Initialize internal streams

    // Disposition Stream
    _internalSub = _recorder.onProgress.listen(
      (RecordingDisposition newProgress) {
        currentProgress = newProgress;
      },
    );

    // Raw Audio Stream
    _pcmController = StreamController<Food>();
    _pcmSub = _pcmController.stream.listen(
      (Food food) {
        if (food is FoodData) {
          _outputFileSink.add(food.data);
        }
      },
    );
  }

  Future<void> _closeStream() async {
    // Close stream
    await _internalSub.cancel();
    _pcmSub.cancel();
    _pcmController.close();
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

  Future<File> _convertPCM(File pcmFile) async {
    // Convert a PCM file to an .aac file
    // Note: Removes the source files

    // Compute Helpful Values
    String parentPath = pcmFile.parent.path;
    String pcmFileName = path.basenameWithoutExtension(pcmFile.path);
    FlutterSoundHelper helper = FlutterSoundHelper();

    // Convert to wave
    String wavePath = path.join(parentPath, '$pcmFileName.wav');
    await helper.pcmToWave(
      inputFile: pcmFile.path,
      outputFile: wavePath,
      sampleRate: 44100,
    );
    pcmFile.deleteSync();

    // Convert to aac
    String aacPath = path.join(parentPath, '$pcmFileName.aac');
    await helper.convertFile(
      wavePath,
      Codec.pcm16WAV,
      aacPath,
      Codec.aacADTS,
    );
    File(wavePath).deleteSync();

    return File(aacPath);
  }
}
