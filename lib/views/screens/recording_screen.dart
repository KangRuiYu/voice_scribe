import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recorder.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/models/recording.dart';

import 'package:voice_scribe/views/widgets/duration_display.dart';
import 'package:voice_scribe/views/widgets/volume_display.dart';

import 'package:voice_scribe/views/widgets/custom_buttons.dart';

class _SaveState extends ChangeNotifier {
  // The saving state (the name inputted and saving functions)
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController get textEditingController => _textEditingController;

  void saveRecording(BuildContext context) async {
    // Save recording and return to previous screen
    Recording recording = await Provider.of<Recorder>(context, listen: false)
        .stopRecording(_textEditingController.text);
    Provider.of<RecordingsManager>(context, listen: false).addRecording(
      recording,
    );
    Navigator.pop(context);
  }

  void deleteRecording(BuildContext context) async {
    // Delete recording and return to previous screen
    Provider.of<Recorder>(context, listen: false).terminate();
    Navigator.pop(context);
  }
}

class RecordingScreen extends StatelessWidget {
  // The screen when recording
  final Recorder _recorder = Recorder();

  RecordingScreen() {
    _recorder.startRecording();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _recorder),
        ChangeNotifierProvider(create: (_) => _SaveState()),
      ],
      child: WillPopScope(
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(title: Text('Recorder')),
            resizeToAvoidBottomPadding: false,
            body: Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 32.0,
                left: 32.0,
                right: 32.0,
              ),
              child: Consumer<Recorder>(builder: (context, recorder, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _DynamicView(),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 40),
                    _DynamicDuration(),
                    const SizedBox(height: 20),
                    _DynamicButtons(),
                  ],
                );
              }),
            ),
          ),
        ),
        onWillPop: () async {
          _recorder.terminate();
          return true;
        },
      ),
    );
  }
}

class _DynamicView extends StatelessWidget {
  // Displays different views based on the state of the recorder
  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(builder: (context, recorder, child) {
      if (recorder.paused)
        return _PausedView();
      else if (recorder.recording)
        return _ActiveView();
      else
        return Center();
    });
  }
}

class _DynamicDuration extends StatelessWidget {
  // Displays duration when active and nothing when not
  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(builder: (context, recorder, child) {
      if (recorder.paused || recorder.recording)
        return DurationDisplay(
          stream: recorder.progress,
          textStyle: Theme.of(context).textTheme.headline5,
        );
      else
        return Center();
    });
  }
}

class _DynamicButtons extends StatelessWidget {
  // Displays different buttons based on the state of the recorder
  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(builder: (context, recorder, child) {
      if (recorder.paused)
        return _PausedButtons();
      else if (recorder.recording)
        return _ActiveButtons();
      else
        return Center();
    });
  }
}

class _ActiveView extends StatelessWidget {
  // The view when active
  @override
  Widget build(BuildContext context) {
    return VolumeDisplay(
      stream: Provider.of<Recorder>(context, listen: false).progress,
      numberOfVolumeBars: 18,
    );
  }
}

class _PausedView extends StatelessWidget {
  // The view when paused
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: Provider.of<_SaveState>(context, listen: false)
            .textEditingController,
        decoration: InputDecoration(
          labelText: 'Recording Name',
        ),
      ),
    );
  }
}

class _ActiveButtons extends StatelessWidget {
  // The buttons when active
  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      leading: Icon(Icons.pause),
      child: Text('Pause'),
      onPressed: Provider.of<Recorder>(context, listen: false).pauseRecording,
    );
  }
}

class _PausedButtons extends StatelessWidget {
  // The buttons when paused
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          child: Text('Save'),
          onPressed: () => Provider.of<_SaveState>(context, listen: false)
              .saveRecording(context),
        ),
        SizedBox(width: 10),
        RoundedButton(
          leading: Icon(Icons.play_arrow),
          child: Text('Resume'),
          onPressed:
              Provider.of<Recorder>(context, listen: false).resumeRecording,
        ),
        SizedBox(width: 10),
        TextButton(
          child: Text('Delete'),
          onPressed: () => Provider.of<_SaveState>(context, listen: false)
              .deleteRecording(context),
        ),
      ],
    );
  }
}
