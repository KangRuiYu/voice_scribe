import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class VolumeDisplay extends StatefulWidget {
  // A widget that displays the volume
  final Stream stream;
  final int numberOfVolumeBars; // Must be a odd number

  const VolumeDisplay(
      {@required this.stream, @required this.numberOfVolumeBars});

  State<VolumeDisplay> createState() {
    return _VolumeDisplayState();
  }
}

class _VolumeDisplayState extends State<VolumeDisplay> {
  double _currentVolume = 0; // In decibels (1 - 120)
  StreamSubscription _subscription;
  Random _random = Random();

  @override
  void initState() {
    // Starts listening on the stream
    _subscription = widget.stream.listen((data) {
      double decibels = data.decibels;
      if (decibels < 0) decibels = 0;
      setState(() => _currentVolume = decibels);
    });
    super.initState();
  }

  double _calculateBarSlope() {
    // Calculate the slope of the volume bars
    num run = (widget.numberOfVolumeBars - 1) / 2;
    num rise = 1 - 0.05;
    double slope = rise / run;
    return slope;
  }

  double _getRandomVolume() {
    // Returns the volume randomized
    double randomizedVolume =
        _currentVolume - (_currentVolume * (0.5 - _random.nextDouble())) * 4;
    return randomizedVolume.clamp(0, 120).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    double slope = _calculateBarSlope();
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...List.generate(((widget.numberOfVolumeBars - 1) ~/ 2).toInt(),
                  (index) {
                double thisSlope = slope * (index + 1);
                return _VolumeBar(
                    volume: _getRandomVolume() * thisSlope,
                    constraints: constraints);
              }),
              _VolumeBar(volume: _getRandomVolume(), constraints: constraints),
              ...List.generate(((widget.numberOfVolumeBars - 1) ~/ 2), (index) {
                double thisSlope =
                    slope * (((widget.numberOfVolumeBars - 1) ~/ 2) - index);
                return _VolumeBar(
                    volume: _getRandomVolume() * thisSlope,
                    constraints: constraints);
              }),
            ],
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

class _VolumeBar extends StatelessWidget {
  static const MIN_VOLUME = 5; // The minimum volume that will be shown
  static const MAX_VOLUME = 80; // The maximum volume that will be shown
  final double volume;
  final constraints;

  _VolumeBar({this.volume, this.constraints});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: constraints.maxWidth * 0.03,
      height: constraints.maxHeight *
          ((volume.clamp(MIN_VOLUME, MAX_VOLUME)) / MAX_VOLUME),
      duration: Duration(seconds: 1),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
