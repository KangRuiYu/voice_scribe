import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class DeepSpeech {
  static const MethodChannel _channel = const MethodChannel('deep_speech_dart');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> initialize(String modelPath) {
    return _channel.invokeMethod('initialize', modelPath);
  }

  Future<int> beamWidth() {
    return _channel.invokeMethod('beamWidth');
  }

  Future<void> setBeamWidth(int beamWidth) {
    return _channel.invokeMethod('setBeamWidth', beamWidth);
  }

  Future<int> sampleRate() {
    return _channel.invokeMethod('sampleRate');
  }

  Future<void> enableExternalScorer(String scorer) {
    return _channel.invokeMethod('enableExternalScorer', scorer);
  }

  Future<void> disableExternalScorer() {
    return _channel.invokeMethod('disableExternalScorer');
  }

  Future<void> setScorerAlphaBeta(double alpha, double beta) {
    return _channel.invokeMethod(
      'setScorerAlphaBeta',
      {'alpha': alpha, 'beta': beta},
    );
  }

  Future<Metadata> sttWithMetadata(
    Uint8List byteBuffer,
    int maxResults,
  ) async {
    return Metadata.fromList(
      await _channel.invokeMethod(
        'sttWithMetadata',
        {'byteBuffer': byteBuffer, 'maxResults': maxResults},
      ),
    );
  }

  Future<void> feedAudioContent(Uint8List byteBuffer) {
    return _channel.invokeMethod('feedAudioContent', byteBuffer);
  }

  Future<String> intermediateDecode() {
    return _channel.invokeMethod('intermediateDecode');
  }

  Future<Metadata> intermediateDecodeWithMetadata(int maxResults) async {
    return Metadata.fromList(await _channel.invokeMethod(
        'intermediateDecodeWithMetadata', maxResults));
  }

  Future<void> addHotWord(String word, double boost) {
    return _channel.invokeMethod('addHotWord', {'word': word, 'boost': boost});
  }

  Future<void> eraseHotWord(String word) {
    return _channel.invokeMethod('eraseHotWord', word);
  }

  Future<void> clearHotWords() {
    return _channel.invokeMethod('clearHotWords');
  }

  Future<String> finish() {
    return _channel.invokeMethod('finish');
  }

  Future<Metadata> finishWithMetadata(int maxResults) async {
    return Metadata.fromList(
        await _channel.invokeMethod('finishWithMetadata', maxResults));
  }
}

class Metadata {
  List<CandidateTranscript> _transcripts;

  int get numTranscripts => _transcripts.length;

  CandidateTranscript getTranscript(int index) {
    return _transcripts[index];
  }

  Metadata(List<CandidateTranscript> _transcripts);

  Metadata.fromList(List<dynamic> transcriptsMapList) {
    _transcripts = [];
    for (Map<dynamic, dynamic> transcriptMap in transcriptsMapList) {
      _transcripts.add(CandidateTranscript.fromMap(transcriptMap));
    }
  }
}

class CandidateTranscript {
  double _confidence;
  List<TokenMetadata> _tokens;

  int get numTokens => _tokens.length;
  double get confidence => _confidence;

  TokenMetadata getToken(int index) {
    return _tokens[index];
  }

  CandidateTranscript({double confidence, List<TokenMetadata> tokens})
      : _confidence = confidence,
        _tokens = tokens;

  CandidateTranscript.fromMap(Map<dynamic, dynamic> transcriptMap)
      : _confidence = transcriptMap['confidence'] {
    _tokens = [];
    for (Map<dynamic, dynamic> tokenMap in transcriptMap['tokens']) {
      _tokens.add(TokenMetadata.fromMap(tokenMap));
    }
  }
}

class TokenMetadata {
  String _text;
  int _timestep;
  double _startTime;

  String get text => _text;
  int get timestep => _timestep;
  double get startTime => _startTime;

  TokenMetadata({String text, int timestep, double startTime})
      : _text = text,
        _timestep = timestep,
        _startTime = startTime;

  TokenMetadata.fromMap(Map<dynamic, dynamic> tokenMap)
      : _text = tokenMap['text'],
        _timestep = tokenMap['timestep'],
        _startTime = tokenMap['startTime'];
}
