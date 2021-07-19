import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:voice_scribe/exceptions/player_exceptions.dart';
import 'package:voice_scribe/models/recording.dart';

class Player extends ChangeNotifier {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  Recording _recording; // The recording being played
  bool _finished = false; // If the recording has finished playing

  // Stream States
  StreamController<PlaybackDisposition> _controller;
  StreamSubscription<PlaybackDisposition>
      _controllerInternalSub; // The stream used by the controller
  StreamSubscription<PlaybackDisposition>
      _internalSub; // The stream used by the player for seeking

  // States
  Stream<PlaybackDisposition> get onProgress => _controller.stream.where(
        (PlaybackDisposition playback) =>
            playback.position >= _startingPosition,
      );
  bool playing = false;
  bool paused = false;
  bool stopped = true;
  bool get opened => _player.isOpen();
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
    _initializeStreams();
  }

  Future<void> close() async {
    // Must close the Player when finished
    if (!_player.isOpen()) throw PlayerAlreadyClosedException();
    await _closeStreams();
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
        _controller.add(
          PlaybackDisposition(
            position: _currentProgress.duration,
            duration: _currentProgress.duration,
          ),
        );
        _finished = true;
        playing = false;
        paused = false;
        stopped = true;
        notifyListeners();
      },
    );

    _currentProgress = PlaybackDisposition.zero();

    playing = true;
    paused = false;
    stopped = false;

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

    playing = false;
    paused = false;
    stopped = true;

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

    playing = false;
    paused = true;

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

    playing = true;
    paused = false;

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

    if (stopped) await restartPlayer();

    await _player.seekToPlayer(duration);

    _startingPosition = duration;

    playing = true;
    paused = false;
    stopped = false;

    notifyListeners();
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
      trackPath: recording.audioPath,
      codec: Codec.pcm16,
    );
  }

  void _initializeStreams() {
    // Initialize internal streams

    // Setup safe stream
    _controller = StreamController<PlaybackDisposition>.broadcast();
    _controllerInternalSub =
        _player.onProgress.where((_) => _controller.hasListener).listen(
      (PlaybackDisposition newProgress) {
        _controller.add(newProgress);
      },
    );

    // Setup internal stream to keep up with the current playback (for seeking)
    _internalSub = _controller.stream.listen(
      (PlaybackDisposition newProgress) {
        _currentProgress = newProgress;
      },
    );
  }

  Future<void> _closeStreams() async {
    // Close streams
    await _internalSub.cancel();
    await _controllerInternalSub.cancel();
    await _controller.close();
  }
}
