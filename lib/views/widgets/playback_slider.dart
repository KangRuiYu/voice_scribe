import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_sound/flutter_sound.dart';

class PlaybackSlider extends StatefulWidget {
  final Stream stream;
  final Function seekPlayerFunc;

  PlaybackSlider({
    @required this.stream,
    @required this.seekPlayerFunc,
  });

  @override
  _PlaybackSliderState createState() => _PlaybackSliderState();
}

class _PlaybackSliderState extends State<PlaybackSlider> {
  StreamSubscription<PlaybackDisposition> _subscription;
  double _end;
  double _currentValue;
  bool _sliding = false; // If the user is currently sliding the bar

  @override
  void initState() {
    _subscription = _listenToStream(widget.stream);
    super.initState();
  }

  StreamSubscription<PlaybackDisposition> _listenToStream(
      Stream<PlaybackDisposition> stream) {
    // Creates a subscription out of the given stream
    return stream.where((_) => !_sliding).listen(
      (PlaybackDisposition playback) {
        _end = playback.duration.inMilliseconds.toDouble();
        setState(
          () => _currentValue = playback.position.inMilliseconds.toDouble(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0,
      max: _end != null ? _end : 1,
      value: _currentValue != null ? _currentValue : 0,
      onChanged: (double value) => setState(() => _currentValue = value),
      onChangeStart: (_) => _sliding = true,
      onChangeEnd: (double value) {
        widget.seekPlayerFunc(Duration(milliseconds: value.toInt()));
        _sliding = false;
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel subscription to the stream
    super.dispose();
  }
}
