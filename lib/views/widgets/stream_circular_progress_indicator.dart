import 'dart:async';

import 'package:flutter/material.dart';

class StreamCircularProgressIndicator extends StatefulWidget {
  final Stream<dynamic> _stream;

  StreamCircularProgressIndicator(Stream<dynamic> stream) : _stream = stream;

  @override
  _StreamCircularProgressIndicatorState createState() =>
      _StreamCircularProgressIndicatorState();
}

class _StreamCircularProgressIndicatorState
    extends State<StreamCircularProgressIndicator> {
  StreamSubscription<dynamic> _subscription;
  double _progress = 0.0;

  @override
  void initState() {
    _subscription = widget._stream.listen(
      (event) {
        setState(() => _progress = event);
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      value: _progress,
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
