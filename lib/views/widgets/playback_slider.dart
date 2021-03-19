import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/player.dart';
import 'package:voice_scribe/utils/formatter.dart';

import 'package:voice_scribe/views/widgets/duration_label.dart';
import 'package:voice_scribe/utils/mono_theme_constants.dart';

class PlaybackSlider extends StatefulWidget {
  // Used to view the current progress of the player playback and to control
  // the positioning of the playback.
  // Note: Expects to be able to access a Player from the given
  // context and for it to be properly initialized before constructing.
  @override
  _PlaybackSliderState createState() => _PlaybackSliderState();
}

class _PlaybackSliderState extends State<PlaybackSlider> {
  StreamSubscription _subscription;
  Function _seekFunc;
  double _end = 1;
  double _currentValue = 0;
  bool _sliding = false; // If the user is currently sliding the bar

  @override
  void initState() {
    _subscription = _listenToStream(
      Provider.of<Player>(context, listen: false).onProgress,
    );
    _seekFunc = Provider.of<Player>(context, listen: false).changePosition;
    super.initState();
  }

  StreamSubscription _listenToStream(Stream stream) {
    // Creates a subscription out of the given stream
    return stream.where((_) => !_sliding).listen(
      (playback) {
        _end = playback.duration.inMilliseconds.toDouble();
        setState(
          () => _currentValue = playback.position.inMilliseconds.toDouble(),
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel subscription to the stream
    super.dispose();
  }

  void onChanged(double value) {
    setState(() => _currentValue = value);
  }

  void onChangeStart(double _) => _sliding = true;

  void onChangeEnd(double value) {
    _seekFunc(Duration(milliseconds: value.toInt()));
    _sliding = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            sliderTheme: SliderTheme.of(context).copyWith(
              trackHeight: PLAYBACK_SLIDER_TRACK_HEIGHT,
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: PLAYBACK_SLIDER_THUMB_SIZE,
              ),
            ),
          ),
          child: Slider(
            label:
                formatDuration(Duration(milliseconds: _currentValue.toInt())),
            divisions: 80,
            min: 0,
            max: _end,
            value: _currentValue,
            onChanged: onChanged,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
          ),
        ),
        const SizedBox(height: PADDING_SMALL),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: PLAYBACK_SLIDER_THUMB_SIZE),
                DurationLabel(),
              ],
            ),
            Row(
              children: [
                DurationLabel(displayProgress: false),
                const SizedBox(width: PLAYBACK_SLIDER_THUMB_SIZE),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
