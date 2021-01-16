import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/models/recording.dart';
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

  void _saveRecording(BuildContext context) async {
    // Save recording and return to previous screen
    var recording =
        await widget._recorder.stopRecording(_textEditingController.text);
    Provider.of<RecordingsManager>(context, listen: false).addRecording(
      Recording(recording),
    );
    Navigator.pop(context);
  }

  void _deleteRecording(BuildContext context) async {
    // Delete recording and return to previous screen
    widget._recorder.terminate();
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
            onResumePressed: widget._recorder.resumeRecording,
            onSavePressed: () => _saveRecording(context),
            onDeletePressed: () => _deleteRecording(context),
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
  final Function onResumePressed; // Called when resume is pressed
  final Function onSavePressed; // Called when save is pressed
  final Function onDeletePressed; // Called when delete is pressed

  _PausedButtons({
    @required this.onResumePressed,
    @required this.onSavePressed,
    @required this.onDeletePressed,
  });

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
          onPressed: onResumePressed,
        ),
        OutlineButton(
          child: Text('Delete'),
          onPressed: onDeletePressed,
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
