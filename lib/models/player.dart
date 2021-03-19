import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'dart:async';

import 'package:voice_scribe/models/recording.dart';

class PlayerAlreadyInitializedException implements Exception {
  static const String _message =
      'Attempted to initialize an already initialized Player.';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class PlayerAlreadyClosedException implements Exception {
  static const String _message = 'Attempted to close a non-open Player';

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class PlayerNotInitializedException implements Exception {
  final String _message;
  PlayerNotInitializedException(this._message);

  @override
  String toString() {
    return '${super.toString()}: $_message';
  }
}

class Player extends ChangeNotifier {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  Recording _recording; // The recording being played
  StreamSubscription<PlaybackDisposition> _internalSub;
  bool _finished = false; // If the recording has finished playing

  // States
  Stream<PlaybackDisposition> get onProgress => _player.onProgress.where(
        (PlaybackDisposition playback) =>
            playback.position >= _startingPosition,
      );
  bool get playing => _player.isPlaying;
  bool get paused => _player.isPaused;
  bool get stopped => _player.isStopped;
  bool get finished => _finished; // If the player just finished a recording
  bool get active => playing || paused; // If the player is in a recording

  Recording get recording => _recording;
  PlaybackDisposition _currentProgress =
      PlaybackDisposition.zero(); // To be able to get the current progress
  Duration _startingPosition = Duration();

  Future<void> initialize() async {
    // Must initialize the Player before using
    if (_player.isOpen()) throw PlayerAlreadyInitializedException();
    await _player.openAudioSession(withUI: true);
    _listenToStream();
  }

  Future<void> close() async {
    // Must close the Player when finished
    if (!_player.isOpen()) throw PlayerAlreadyClosedException();
    await _closeStream();
    await _player.closeAudioSession();
  }

  Future<void> startPlayer(Recording recording) async {
    // Starts playing the given recording file
    if (!_player.isOpen())
      throw PlayerNotInitializedException(
        'Attempted to start player without initializing it.',
      );
    if (active) await stopPlayer(); // Stop player if currently playing

    _finished = false;
    _recording = recording;
    _startingPosition = Duration();
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

    _currentProgress = PlaybackDisposition.zero();

    notifyListeners();
  }

  Future<void> stopPlayer() async {
    // Stops recording
    if (!_player.isOpen())
      throw PlayerNotInitializedException(
        'Attempted to stop a player that is not initialized',
      );
    if (stopped) return; // Return if already stopped
    await _player.stopPlayer();
    notifyListeners();
  }

  Future<void> pausePlayer() async {
    // Pause the player
    if (!_player.isOpen()) {
      throw PlayerNotInitializedException(
        'Attempted to pause a player that is not initialized',
      );
    }
    if (paused || stopped) return;
    await _player.pausePlayer();
    notifyListeners();
  }

  Future<void> resumePlayer() async {
    // Resume the player
    if (!_player.isOpen()) {
      throw PlayerNotInitializedException(
        'Attempted to resume a player that is not initialized',
      );
    }
    if (playing || stopped) return;
    await _player.resumePlayer();
    notifyListeners();
  }

  Future<void> restartPlayer() async {
    // Restarts the player to play the last recording
    if (!_player.isOpen()) {
      throw PlayerNotInitializedException(
        'Attempted to restart a player that is not initialized',
      );
    }
    if (recording == null) return; // Terminate if no recording found
    await startPlayer(recording);
  }

  Future<void> changePosition(Duration duration) async {
    // Changes the players position. Must be playing or paused.
    if (!_player.isOpen()) {
      throw PlayerNotInitializedException(
        'Attempted to change position of a player that is not initialized',
      );
    }
    if (recording == null) return;

    // Clamp duration
    if (duration.isNegative)
      duration = Duration();
    else if (duration > _currentProgress.duration)
      duration = _currentProgress.duration;

    if (stopped) {
      // Restart player if it has finished
      await restartPlayer();
    }

    bool wasPaused = paused;

    await _player.seekToPlayer(duration);

    _startingPosition = duration;

    if (wasPaused) {
      // Notify listeners of state change (seekToPlayer resumes playback)
      notifyListeners();
    }
  }

  Future<void> changePositionRelative(Duration duration) async {
    // Change the players position relative to its current position. Positive is forward.
    Duration newPosition = _currentProgress.position + duration;
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
      // Player needs the raw stream to accurately change position
      (PlaybackDisposition newProgress) {
        _currentProgress = newProgress;
      },
    );
  }

  Future<void> _closeStream() async {
    // Stops listening to the stream
    await _internalSub.cancel();
  }
}
