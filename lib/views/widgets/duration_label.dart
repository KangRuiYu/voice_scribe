import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/player.dart';

import 'package:voice_scribe/utils/formatter.dart';

class DurationLabel extends StatefulWidget {
  final bool displayProgress;
  final TextStyle textStyle;

  DurationLabel({
    this.displayProgress = true,
    this.textStyle,
  });

  @override
  _DurationLabelState createState() => _DurationLabelState();
}

class _DurationLabelState extends State<DurationLabel> {
  Duration _currentDuration = Duration();
  StreamSubscription _subscription;

  @override
  void initState() {
    _listenToStream(Provider.of<Player>(context, listen: false).onProgress);
    super.initState();
  }

  void _listenToStream(Stream stream) {
    // Starts listening on the stream
    _subscription = stream.listen(
      (data) {
        if (widget.displayProgress)
          setState(() => _currentDuration = data.position);
        else
          setState(() => _currentDuration = data.duration);
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