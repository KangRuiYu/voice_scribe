import 'dart:async';
import 'package:flutter/material.dart';

class VolumeDisplay extends StatefulWidget {
  // A widget that displays the volume
  final Stream _stream;
  final bool right; // Whether the display is aligned left or right

  VolumeDisplay(this._stream, this.right);

  State<VolumeDisplay> createState() {
    return _VolumeDisplayState();
  }
}

class _VolumeDisplayState extends State<VolumeDisplay> {
  double _currentVolume = 0; // In decibels (1 - 120)
  StreamSubscription _subscription;

  void initState() {
    // Starts listening on the stream
    _subscription = widget._stream.listen((data) {
      setState(() => _currentVolume = data.decibels);
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment:
                widget.right ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
              width:
                  (constraints.maxWidth * 0.8) * (_currentVolume / 40),
              height: constraints.maxHeight * 0.05,
              duration: Duration(seconds: 1),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel subscription to the stream
    super.dispose();
  }
}
