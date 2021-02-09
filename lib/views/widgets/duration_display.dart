import 'dart:async';
import 'package:flutter/material.dart';

import 'package:voice_scribe/utils/formatter.dart';

class DurationDisplay extends StatefulWidget {
  // A widget that displays a duration from the given stream
  final Stream stream;
  final TextStyle textStyle;
  final bool useDuration;

  DurationDisplay({
    this.stream,
    this.textStyle,
    this.useDuration = true,
  });

  State<DurationDisplay> createState() {
    return _DurationDisplayState();
  }
}

class _DurationDisplayState extends State<DurationDisplay> {
  // The state of the Duration Display widget
  Duration _currentDuration = Duration();
  StreamSubscription _subscription;

  @override
  void initState() {
    // Starts listening on the stream
    _subscription = widget.stream.listen((data) {
      if (widget.useDuration)
        setState(() => _currentDuration = data.duration);
      else
        setState(() => _currentDuration = data.position);
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Text(
      formatDuration(_currentDuration),
      style: widget.textStyle,
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel subscription to the stream
    super.dispose();
  }
}
