import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'dart:async';

import 'package:voice_scribe/models/recordings_manager.dart';

class Player extends ChangeNotifier {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  RecordingInfo _recording; // The recording being played
  StreamSubscription _progressSubscription;

  bool get playing => _player.isPlaying;
  bool get paused => _player.isPaused;
  RecordingInfo get recording => _recording;
  Stream<PlaybackDisposition> get progress => _player.onProgress;
  PlaybackDisposition currentProgress; // To be able to get the current position

  void startPlayer(RecordingInfo recording, Function onFinished) async {
    // Starts playing the given recording file
    _recording = recording;
    await _openAudioSession();
    await _player.setSubscriptionDuration(Duration(milliseconds: 100));
    await _player.startPlayer(
      fromURI: _recording.path,
      whenFinished: onFinished,
    );

    _listenToStream();

    notifyListeners();
  }

  void stopPlayer() async {
    // Stops recording
    await _closeStream();
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
    if (duration.isNegative)
      await changePosition(Duration(seconds: 0));
    else if (duration > currentProgress.duration)
      await changePosition(currentProgress.duration);
    else
      await _player.seekToPlayer(duration);
  }

  void changePositionRelative(Duration duration) async {
    // Change the players position relative to its current position. Positive is forward.
    Duration newPosition = currentProgress.position + duration;
    await changePosition(newPosition);
  }

  void _openAudioSession() async {
    await _player.openAudioSession();
  }

  void _closeAudioSession() async {
    await _player.closeAudioSession();
  }

  void _listenToStream() {
    // Begins listening to progress stream
    _progressSubscription =
        _player.onProgress.listen((PlaybackDisposition newProgress) {
      currentProgress = newProgress;
    });
  }

  void _closeStream() async {
    // Stops listening to the stream
    await _progressSubscription.cancel();
  }
}
