import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'dart:async';

import 'package:voice_scribe/models/recording.dart';

class Player extends ChangeNotifier {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  Recording _recording; // The recording being played
  Stream<PlaybackDisposition> _playback;
  StreamSubscription<PlaybackDisposition> _playbackSubscription;
  bool _finished = false; // If the recording has finished playing
  bool _mutePlayback =
      false; // True if player is going to stop reporting the playback stream

  // States
  bool get playing => _player.isPlaying;
  bool get paused => _player.isPaused;
  bool get stopped => _player.isStopped;
  bool get finished => _finished; // If the player just finished a recording
  bool get active => playing || paused; // If the player is in a recording

  Recording get recording => _recording;
  PlaybackDisposition currentPlayback; // To be able to get the current position

  void startPlayer(Recording recording, [startSession = true]) async {
    // Starts playing the given recording file
    _finished = false;
    _recording = recording;
    if (startSession) await _openAudioSession();
    await _player.setSubscriptionDuration(Duration(milliseconds: 100));
    await _player.startPlayer(
      fromURI: _recording.path,
      whenFinished: () {
        _finished = true;
        notifyListeners();
      },
    );

    _listenToStream();

    notifyListeners();
  }

  void stopPlayer([closeSession = true]) async {
    // Stops recording
    await _closeStream();
    await _player.stopPlayer();
    if (closeSession) await _closeAudioSession();
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

  void restartPlayer() async {
    // Restarts the player to play the last recording
    if (_recording == null) // End if no recording found
      return;

    if (active || finished) {
      // Stop player without ending the session if active or finished
      await stopPlayer(false);
    }

    await startPlayer(recording, false);
  }

  void changePosition(Duration duration) async {
    // Changes the players position. Must be playing or paused.
    if (duration.isNegative) {
      await changePosition(Duration(seconds: 0));
    } else if (duration > currentPlayback.duration) {
      await changePosition(currentPlayback.duration);
    } else {
      if (finished) {
        _mutePlayback = true;
        await restartPlayer();
      }
      await _player.seekToPlayer(duration);
      _mutePlayback = false;
    }
  }

  void changePositionRelative(Duration duration) async {
    // Change the players position relative to its current position. Positive is forward.
    Duration newPosition = currentPlayback.position + duration;
    await changePosition(newPosition);
  }

  Stream<PlaybackDisposition> playbackInfo() async* {
    // Returns a safe playback stream. One that will produce values even when the player is not ready
    PlaybackDisposition latestPlayback = PlaybackDisposition.zero();
    StreamSubscription<PlaybackDisposition> internalSub = _player.onProgress
        .where((_) => !_mutePlayback)
        .listen((PlaybackDisposition newPlayback) {
      latestPlayback = newPlayback;
    });

    try {
      while (true) {
        await Future.delayed(Duration(milliseconds: 100));
        yield latestPlayback;
      }
    } finally {
      internalSub.cancel();
    }
  }

  void _openAudioSession() async {
    await _player.openAudioSession();
  }

  void _closeAudioSession() async {
    await _player.closeAudioSession();
  }

  void _listenToStream() {
    // Begins listening to progress stream
    _playbackSubscription =
        playbackInfo().listen((PlaybackDisposition newProgress) {
      currentPlayback = newProgress;
    });
  }

  void _closeStream() async {
    // Stops listening to the stream
    await _playbackSubscription.cancel();
  }
}
