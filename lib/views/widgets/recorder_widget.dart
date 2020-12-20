import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recorder.dart';

import 'package:voice_scribe/views/widgets/custom_buttons.dart';
import 'package:voice_scribe/views/widgets/duration_display.dart';
import 'package:voice_scribe/views/widgets/volume_display.dart';

class RecorderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(builder: (context, recorder, child) {
      if (recorder.paused)
        return _PausedControls(recorder);
      else if (recorder.recording)
        return _RecordingControls(recorder);
      else
        return Center();
    });
  }
}

class _PausedControls extends StatelessWidget {
  // Displayed when paused, showing resume and stop buttons
  final Recorder _recorder;

  _PausedControls(this._recorder);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Recording Name',
            ),
          ),
          SizedBox(height: 20),
          _PausedButtons(_recorder),
        ],
      ),
    );
  }
}

class _PausedButtons extends StatelessWidget {
  // The buttons in the paused controls
  final Recorder _recorder;

  _PausedButtons(this._recorder);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlineButton(
          child: Text('Save'),
          onPressed: () {
            Navigator.pop(context);
            _recorder.stopRecording();
          },
        ),
        CircularIconButton(
          iconData: Icons.play_arrow,
          onPressed: _recorder.resumeRecording,
        ),
        OutlineButton(
          child: Text('Delete'),
          onPressed: () => null,
        ),
      ],
    );
  }
}

class _RecordingControls extends StatelessWidget {
  // Displayed when recording, showing record time, volume, and a pause button
  final Recorder _recorder;

  _RecordingControls(this._recorder);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VolumeDisplay(stream: _recorder.progress, numberOfVolumeBars: 15),
          const SizedBox(height: 20),
          DurationDisplay(
            stream: _recorder.progress,
            textStyle: Theme.of(context).textTheme.headline2,
          ),
          const SizedBox(height: 20),
          CircularIconButton(
            iconData: Icons.pause,
            onPressed: _recorder.pauseRecording,
          ),
        ],
      ),
    );
  }
}
