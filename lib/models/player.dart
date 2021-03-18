import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'dart:async';

import 'package:voice_scribe/models/recording.dart';

class Player extends ChangeNotifier {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  Recording _recording; // The recording being played
  StreamSubscription<PlaybackDisposition> _internalSub;
  bool _finished = false; // If the recording has finished playing
  bool _mutePlayback =
      false; // True if player is going to stop reporting the playback stream

  // States
  Stream<PlaybackDisposition> get onProgress => _player.onProgress;
  bool get playing => _player.isPlaying;
  bool get paused => _player.isPaused;
  bool get stopped => _player.isStopped;
  bool get finished => _finished; // If the player just finished a recording
  bool get active => playing || paused; // If the player is in a recording

  Recording get recording => _recording;
  PlaybackDisposition currentProgress =
      PlaybackDisposition.zero(); // To be able to get the current progress

  Future<void> initialize() async {
    // Must initialize the Player before using
    await _player.openAudioSession(withUI: true);
  }

  Future<void> close() async {
    // Must close the Player when finished
    await _player.closeAudioSession();
  }

  Future<void> startPlayer(Recording recording) async {
    // Starts playing the given recording file
    _finished = false;
    _recording = recording;
    await _player.setSubscriptionDuration(Duration(milliseconds: 100));

    await _player.startPlayerFromTrack(
      _recordingToTrack(recording),
      onPaused: (bool pause) {
        if (pause)
          pausePlayer();
        else
          resumePlayer();
      },
      onSkipForward: () => null,
      onSkipBackward: () => null,
      defaultPauseResume: false,
      removeUIWhenStopped: true,
      whenFinished: () {
        _finished = true;
        notifyListeners();
      },
    );

    currentProgress = PlaybackDisposition.zero();
    _listenToStream();

    notifyListeners();
  }

  Future<void> stopPlayer() async {
    // Stops recording
    await _closeStream();
    await _player.stopPlayer();
    notifyListeners();
  }

  Future<void> pausePlayer() async {
    // Pause the player
    await _player.pausePlayer();
    notifyListeners();
  }

  Future<void> resumePlayer() async {
    // Resume the player
    await _player.resumePlayer();
    notifyListeners();
  }

  Future<void> restartPlayer() async {
    // Restarts the player to play the last recording
    if (_recording == null) // End if no recording found
      return;

    if (active || finished) {
      // Stop player without ending the session if active or finished
      await stopPlayer();
    }

    await startPlayer(recording);
  }

  Future<void> changePosition(Duration duration) async {
    // Changes the players position. Must be playing or paused.
    _mutePlayback = true;

    // Clamp duration
    if (duration.isNegative)
      duration = Duration();
    else if (duration > currentProgress.duration)
      duration = currentProgress.duration;

    if (finished) {
      // Restart player if it has finished
      await restartPlayer();
    }

    bool wasPaused = paused;

    await _player.seekToPlayer(duration);

    if (wasPaused) {
      // Notify listeners of state change (seekToPlayer resumes playback)
      notifyListeners();
    }

    _mutePlayback = false;
  }

  Future<void> changePositionRelative(Duration duration) async {
    // Change the players position relative to its current position. Positive is forward.
    Duration newPosition = currentProgress.position + duration;
    await changePosition(newPosition);
  }

  Track _recordingToTrack(Recording recording) {
    // Returns a track converted from a recording
    return Track(
      trackTitle: recording.name,
      trackAuthor: 'Unknown author',
      trackPath: recording.path,
    );
  }

  void _listenToStream() {
    // Begins listening to progress stream
    _internalSub = _player.onProgress.listen(
      (PlaybackDisposition newProgress) {
        currentProgress = newProgress;
      },
    );
  }

  Future<void> _closeStream() async {
    // Stops listening to the stream
    await _internalSub.cancel();
  }
}
