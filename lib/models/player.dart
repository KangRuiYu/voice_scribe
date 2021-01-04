import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'dart:io';

import 'package:voice_scribe/models/recordings_manager.dart';

class Player extends ChangeNotifier {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  RecordingInfo _recording; // The recording being played

  bool get playing => _player.isPlaying;
  bool get paused => _player.isPaused;
  RecordingInfo get recording => _recording;
  Stream<PlaybackDisposition> get progress => _player.onProgress;

  void startPlayer(RecordingInfo recording, Function onFinished) async {
    // Starts playing the given recording file
    _recording = recording;
    await _openAudioSession();
    await _player.setSubscriptionDuration(Duration(milliseconds: 100));
    await _player.startPlayer(
      fromURI: _recording.path,
      whenFinished: onFinished,
    );
    notifyListeners();
  }

  void stopPlayer() async {
    // Stops recording
    await _player.stopPlayer();
    await _closeAudioSession();
    notifyListeners();
  }

  void pausePlayer() async {
    // Pause the player
    await _player.pausePlayer();
    notifyListeners();
  }

  void resumePlayer() async {
    // Resume the player
    await _player.resumePlayer();
    notifyListeners();
  }

  void changePosition(Duration duration) async {
    // Changes the players position. Must be playing or paused.
    await _player.seekToPlayer(duration);
  }

  void _openAudioSession() async {
    await _player.openAudioSession();
  }

  void _closeAudioSession() async {
    await _player.closeAudioSession();
  }
}
