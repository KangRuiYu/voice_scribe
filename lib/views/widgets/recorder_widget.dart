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

class _PausedControls extends StatefulWidget {
  // Displayed when paused (resume/save/delete buttons and recording name field)
  final Recorder _recorder;

  _PausedControls(this._recorder);

  @override
  State<_PausedControls> createState() {
    return _PausedControlsState();
  }
}

class _PausedControlsState extends State<_PausedControls> {
  TextEditingController _textEditingController = TextEditingController();

  void _saveRecording() {
    widget._recorder.stopRecording(_textEditingController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              labelText: 'Recording Name',
            ),
          ),
          SizedBox(height: 20),
          _PausedButtons(
            recorder: widget._recorder,
            onSavePressed: _saveRecording,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

class _PausedButtons extends StatelessWidget {
  // The buttons in the paused controls
  final Recorder recorder;
  final Function onSavePressed; // Called when save is pressed

  _PausedButtons({this.recorder, this.onSavePressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlineButton(
          child: Text('Save'),
          onPressed: onSavePressed,
        ),
        CircularIconButton(
          iconData: Icons.play_arrow,
          onPressed: recorder.resumeRecording,
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
