import 'dart:async';
import 'package:flutter/material.dart';

class PlaybackSlider extends StatefulWidget {
  final Stream stream;
  final Function onChange;

  PlaybackSlider(this.stream, this.onChange);

  @override
  _PlaybackSliderState createState() => _PlaybackSliderState();
}

class _PlaybackSliderState extends State<PlaybackSlider> {
  StreamSubscription _subscription;
  Duration _end;
  Duration _currentPosition;

  @override
  void initState() {
    _subscription = widget.stream.listen((data) {
      _end = data.duration;
      setState(() => _currentPosition = data.position);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0,
      max: _end != null ? _end.inMilliseconds.toDouble() : 1,
      value: _end != null ? _currentPosition.inMilliseconds.toDouble() : 0,
      onChanged: widget.onChange,
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel subscription to the stream
    super.dispose();
  }
}
