import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recorder.dart';

import 'package:voice_scribe/views/custom_buttons.dart';
import 'package:voice_scribe/views/duration_display.dart';
import 'package:voice_scribe/views/volume_display.dart';

class RecorderDisplay extends StatelessWidget {
  // A recorder display
  final _recorder;

  RecorderDisplay(this._recorder);

  Widget build(BuildContext context) {
    if (_recorder.paused) {
      return Text('Paused');
    } else {
      return Text('Playing');
    }
  }
}

class MiniRecorderDisplay extends StatelessWidget {
  // A slim recorder display (Needs to be nested under a ChangeNotifierProvider to work)
  final _recorder;

  MiniRecorderDisplay(this._recorder);

  Widget build(BuildContext context) {
    if (_recorder.paused) {
      return _MiniPausedControls(_recorder);
    } else {
      return _MiniRecordingControls(_recorder);
    }
  }
}

class _MiniPausedControls extends StatelessWidget {
  // Displayed when paused, showing resume and stop buttons
  final Recorder _recorder;

  _MiniPausedControls(this._recorder);

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularIconButton(
          iconData: Icons.stop,
          onPressed: _recorder.stopRecording,
        ),
        CircularIconButton(
          iconData: Icons.play_arrow,
          onPressed: _recorder.resumeRecording,
        ),
      ],
    );
  }
}

class _MiniRecordingControls extends StatelessWidget {
  // Displayed when recording, showing record time, volume, and a pause button
  final Recorder _recorder;

  _MiniRecordingControls(this._recorder);

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        VolumeDisplay(_recorder.progress, true),
        const SizedBox(width: 8),
        RoundedButton(
          child: Row(
            children: [
              DurationDisplay(_recorder.progress),
              const SizedBox(width: 8),
              Icon(Icons.pause),
            ],
          ),
          onPressed: _recorder.pauseRecording,
        ),
        const SizedBox(width: 8),
        VolumeDisplay(_recorder.progress, false),
      ],
    );
  }
}
