import 'dart:async';

import 'package:flutter/material.dart';

class DurationDisplay extends StatefulWidget {
  // A widget that displays a duration from the given stream
  final Stream _stream;

  DurationDisplay(this._stream);

  State<DurationDisplay> createState() {
    return _DurationDisplayState();
  }
}

class _DurationDisplayState extends State<DurationDisplay> {
  // The state of the Duration Display widget
  double _currentDuration = 0;
  StreamSubscription _subscription;

  void initState() {
    // Starts listening on the stream
    _subscription = widget._stream.listen((data) {
      var seconds = data.duration.inMilliseconds / 1000;
      setState(() => _currentDuration = seconds);
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Text(
      _currentDuration.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel subscription to the stream
    super.dispose();
  }
}
