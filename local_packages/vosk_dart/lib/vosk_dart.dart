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

  // Constructor will fail if given a model that doesn't exist or a sample
  // rate that is non-positive.
  Vosk({@required String modelPath, int sampleRate = 16000})
      : _modelPath = modelPath,
        _sampleRate = sampleRate {
    if (!Directory(modelPath).existsSync()) throw NonExistentModel();
    if (sampleRate <= 0) throw NonPositiveSampleRate();
  }

  Future<void> transcribeWavFile(String filePath) {
    if (!File(filePath).existsSync()) throw NonExistentWavFile();
    _channel.invokeMethod('transcribeWavFile', {
      'modelPath': _modelPath,
      'sampleRate': _sampleRate,
      'filePath': filePath
    });
    return null;
  }
}
