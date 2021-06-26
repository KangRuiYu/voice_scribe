import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vosk_dart/vosk_exceptions.dart';

class Vosk {
  static const MethodChannel _channel = const MethodChannel('vosk_dart');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  final String _modelPath;
  final int _sampleRate;

  String get modelPath => _modelPath;
  int get sampleRate => sampleRate;

  bool _opened = false;

  // Constructor will fail if given a model that doesn't exist or a sample
  // rate that is non-positive.
  Vosk({@required String modelPath, int sampleRate = 16000})
      : _modelPath = modelPath,
        _sampleRate = sampleRate {
    if (!Directory(modelPath).existsSync()) throw NonExistentModel();
    if (sampleRate <= 0) throw NonPositiveSampleRate();
  }

  // Opens the transcriber for use. Most methods will only work with
  // an opened transcriber.
  Future<void> open() async {
    if (_opened) throw TranscriberAlreadyOpened();
    await _channel.invokeMethod(
      'open',
      {
        'modelPath': _modelPath,
        'sampleRate': _sampleRate,
      },
    );
    _opened = true;
  }

  // Modify the debug mode, which changes how much output is printed into
  // the console.
  Future<void> setDebug(bool on) {
    _checkIsOpen();
    return _channel.invokeMethod('setDebug', on);
  }

  // Gives an audio buffer to the transcriber. The length of the given buffer
  // must be even.
  Future<void> feedAudioBuffer(Uint8List byteBuffer) {
    _checkIsOpen();
    if (byteBuffer.length.isOdd) throw OddBufferLength();
    return _channel.invokeMethod('feedAudioBuffer', byteBuffer);
  }

  // Gives the audio buffer of the given file to the transcriber. The given
  // file must exist or an exception will be thrown.
  Future<void> feedWavFile(String filePath) {
    _checkIsOpen();
    if (!File(filePath).existsSync()) throw NonExistentWavFile();
    return _channel.invokeMethod('feedWavFile', filePath);
  }

  // Returns the partial result of the ongoing transcription process.
  Future<String> getPartialResult() {
    _checkIsOpen();
    return _channel.invokeMethod('getPartialResult');
  }

  // Closes the transcriber and returns the final result. If the transcriber
  // is not opened, then nothing happens.
  Future<String> close() async {
    if (!_opened) return null;

    String finalResult = await _channel.invokeMethod('getFinalResult');
    await _channel.invokeMethod('close');
    _opened = false;
    return finalResult;
  }

  // Private helper method that throws an exception when ran on a non-opened
  // transcriber.
  void _checkIsOpen() {
    if (!_opened) throw TranscriberNotOpened();
  }
}
