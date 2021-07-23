import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player.dart';
import '../../models/recorder.dart';
import '../../utils/formatter.dart';

class DurationLabel extends StatefulWidget {
  // Displays duration of Player or Recorder.
  // Note: Expects to be able to access a Player/Recorder from the given
  // context and for it to be properly initialized before constructing.
  final bool _player; // If showing duration for the player
  final bool displayDuration;
  final TextStyle textStyle;

  DurationLabel.player({
    this.displayDuration = true,
    this.textStyle,
  }) : _player = true;

  DurationLabel.recorder({this.textStyle})
      : _player = false,
        displayDuration = true;

  @override
  _DurationLabelState createState() => _DurationLabelState();
}

class _DurationLabelState extends State<DurationLabel> {
  Duration _currentDuration = Duration();
  StreamSubscription _subscription;

  @override
  void initState() {
    if (widget._player) {
      _listenToStream(Provider.of<Player>(context, listen: false).onProgress);
    } else {
      _listenToStream(Provider.of<Recorder>(context, listen: false).onProgress);
    }
    super.initState();
  }

  void _listenToStream(Stream stream) {
    // Starts listening on the stream
    _subscription = stream.listen(
      (data) {
        if (widget.displayDuration)
          setState(() => _currentDuration = data.duration);
        else
          setState(() => _currentDuration = data.position);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(_currentDuration),
      style: widget.textStyle == null
          ? Theme.of(context).textTheme.subtitle1
          : widget.textStyle,
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel subscription to the stream
    super.dispose();
  }
}
