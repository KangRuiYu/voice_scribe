import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/constants/theme_constants.dart' as theme_constants;
import 'package:voice_scribe/models/audio/player.dart';
import 'package:voice_scribe/utils/formatter.dart' as formatter;

/// Displays player progress and allows playback to be repositioned.
///
/// Note: Expects to be able to access a Player from the given
/// context and for it to be properly initialized before constructing.
class PlaybackSlider extends StatefulWidget {
  const PlaybackSlider();

  @override
  _PlaybackSliderState createState() => _PlaybackSliderState();
}

class _PlaybackSliderState extends State<PlaybackSlider> {
  /// Internal subscription to player progress.
  StreamSubscription _subscription;

  /// Function called when changing positions.
  Function _seekFunc;

  /// Last recorded playback from the player.
  PlaybackDisposition _lastPlayback = PlaybackDisposition.zero();

  /// Last selected position from user.
  Duration _selectedPosition = Duration.zero;

  /// If user is currently moving the slider.
  bool _sliding = false; // If the user is currently sliding the bar

  @override
  void initState() {
    _subscription = _listenToPlayer();
    _seekFunc = context.read<Player>().changePosition;
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel subscription to the stream
    super.dispose();
  }

  /// Returns a subscription to the nearest [Player]'s progress stream.
  StreamSubscription<PlaybackDisposition> _listenToPlayer() {
    Stream<PlaybackDisposition> onProgress = context.read<Player>().onProgress;
    return onProgress.where((_) => !_sliding).listen(
      (PlaybackDisposition playback) {
        setState(() => _lastPlayback = playback);
      },
    );
  }

  void onChanged(double value) => setState(
        () => _selectedPosition = Duration(milliseconds: value.toInt()),
      );

  void onChangeStart(double _) => _sliding = true;

  void onChangeEnd(double value) {
    Duration newPosition = Duration(milliseconds: value.toInt());
    _seekFunc(newPosition);
    _lastPlayback = PlaybackDisposition(
      position: newPosition,
      duration: _lastPlayback.duration,
    );
    _sliding = false;
  }

  @override
  Widget build(BuildContext context) {
    final SliderThemeData sliderTheme = SliderTheme.of(context).copyWith(
      trackHeight: theme_constants.bar_height,
      overlayShape: const RoundSliderOverlayShape(
        overlayRadius: theme_constants.slider_thumb_size,
      ),
    );

    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(sliderTheme: sliderTheme),
          child: Slider(
            min: 0,
            max: _lastPlayback.duration.inMilliseconds.toDouble(),
            value: _sliding
                ? _selectedPosition.inMilliseconds.toDouble()
                : _lastPlayback.position.inMilliseconds.toDouble(),
            onChanged: onChanged,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
          ),
        ),
        const SizedBox(height: theme_constants.padding_small),
        _DurationProgressLabels(
          currentPosition:
              _sliding ? _selectedPosition : _lastPlayback.position,
          totalDuration: _lastPlayback.duration,
        ),
      ],
    );
  }
}

/// The labels that show the current and total duration of the current [Player]
/// playback.
class _DurationProgressLabels extends StatelessWidget {
  final Duration currentPosition;
  final Duration totalDuration;

  const _DurationProgressLabels({
    @required this.currentPosition,
    @required this.totalDuration,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.subtitle1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: theme_constants.slider_thumb_size),
            Text(formatter.formatDuration(currentPosition), style: style),
          ],
        ),
        Row(
          children: [
            Text(formatter.formatDuration(totalDuration), style: style),
            const SizedBox(width: theme_constants.slider_thumb_size),
          ],
        ),
      ],
    );
  }
}
