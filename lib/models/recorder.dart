import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:voice_scribe/models/recording.dart';
import 'package:deep_speech_dart/deep_speech_dart.dart';

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
  StreamSubscription<RecordingDisposition> _internalSub;
  StreamController<FoodData> _audioData;
  RecordingFileStream _recordingFileStream;

  // States
  Stream<RecordingDisposition> get onProgress => _recorder.onProgress;
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

  Future<void> startRecording() async {
    // Starts the recording process
    if (!opened) {
      throw RecorderNotInitializedException(
        'Attempted to start recorder without initializing it',
      );
    }
    if (active) await terminate(); // Stop recorder if currently recording

    // Create new recording file
    _recordingFileStream = RecordingFileStream(
      directoryPath: (await getExternalStorageDirectory()).path,
      fileName: _generateName(),
      audioStream: _audioData.stream,
    );

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      toStream: _audioData.sink,
      sampleRate: 16000,
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
    File finalFile = await _recordingFileStream.close();

    // Rename file if a recording name is given
    if (recordingName.isNotEmpty) {
      String newPath = path.join(finalFile.parent.path, '$recordingName.wav');
      finalFile = finalFile.renameSync(newPath);
    }

    Recording recording = Recording(
      file: finalFile,
      duration: currentProgress.duration,
    );
    _recordingFileStream = null;

    DeepSpeech transcriber = DeepSpeech();
    String modelPath = path.join(
      (await getExternalStorageDirectory()).path,
      'deepspeech-0.9.2-models.tflite',
    );
    await transcriber.initialize(modelPath);
    await transcriber.feedAudioContent(finalFile.readAsBytesSync());
    print(await transcriber.finish());

    notifyListeners();

    return recording;
  }

  Future<void> terminate() async {
    // Stops any ongoing recording and clean up any files left over
    // Note: Must still close the recorder after
    await _recorder.stopRecorder();

    File leftOverFile = await _recordingFileStream.close();

    leftOverFile.delete();
    _recordingFileStream = null;
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

  String _generateName() {
    // Generates a unique name based on the current time (down to the second)
    DateTime date = DateTime.now();
    return '${date.month}-${date.day}-${date.year}-${date.hour}-${date.minute}-${date.second}';
  }
}

// Handles the writing of a wav file
class RecordingFileStream {
  static final FlutterSoundHelper helper = FlutterSoundHelper();

  StreamSubscription<Food> _audioSubscription; // The sub to the audio data

  File _outputFile; // The file being written to
  IOSink _outputFileSink; // The IOStream of the output file

  bool _addedHeader = false;

  RecordingFileStream({
    String directoryPath,
    String fileName,
    Stream<FoodData> audioStream,
  }) {
    _outputFile = File(path.join(directoryPath, '$fileName.wav'));
    _outputFileSink = _outputFile.openWrite();

    _audioSubscription = audioStream.listen(
      (Food food) async {
        if (food is FoodData) {
          if (_addedHeader) {
            _outputFileSink.add(food.data);
          } else {
            var newBuffer =
                await helper.pcmToWaveBuffer(inputBuffer: food.data);
            _outputFileSink.add(
              newBuffer,
            );
            _addedHeader = true;
          }
        }
      },
    );
  }

  // Ends the output stream, returning the final wav file.
  Future<File> close() async {
    await _audioSubscription.cancel();
    await _outputFileSink.flush();
    await _outputFileSink.close();
    await updateWavHeaderByteInfo();
    return _outputFile;
  }

  // Updates the recorded byte length of the data in the wav header of the file.
  Future<void> updateWavHeaderByteInfo() async {
    RandomAccessFile fileAccess = await _outputFile.open(mode: FileMode.append);
    await fileAccess.setPosition(41);

    Uint8List intAsByteBuffer = Uint8List(4);
    intAsByteBuffer.buffer.asByteData().setInt32(
          0,
          fileAccess.lengthSync() - 44,
          Endian.little,
        );

    await fileAccess.writeFrom(intAsByteBuffer);

    fileAccess.close();
  }
}
