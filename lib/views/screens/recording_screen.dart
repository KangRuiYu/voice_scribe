import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recorder.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/models/recording.dart';

import 'package:voice_scribe/views/widgets/duration_label.dart';
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
    Provider.of<RecordingsManager>(context, listen: false).addNewRecording(
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
          child: _RecordingScreenScaffold(),
        ),
        onWillPop: () async {
          _recorder.terminate();
          return true;
        },
      ),
    );
  }
}

class _RecordingScreenScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recorder')),
      // resizeToAvoidBottomPadding: false,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 0,
          bottom: 32.0,
          left: 32.0,
          right: 32.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RecordingView(),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 40),
            _PresuppliedDuration(),
            const SizedBox(height: 20),
            _Buttons(),
          ],
        ),
      ),
    );
  }
}

class _RecordingView extends StatelessWidget {
  // Displays different views based on the state of the recorder
  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(builder: (context, recorder, child) {
      if (recorder.recording) {
        // While recording
        return VolumeDisplay(
          stream: Provider.of<Recorder>(context, listen: false).progressInfo(),
          numberOfVolumeBars: 18,
        );
      } else {
        // While paused
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
    });
  }
}

class _PresuppliedDuration extends StatelessWidget {
  // Displays duration when active and nothing when not
  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(builder: (context, recorder, child) {
      return DurationLabel(
        textStyle: Theme.of(context).textTheme.headline5,
        expectPlayer: false,
      );
    });
  }
}

class _Buttons extends StatelessWidget {
  // Displays different buttons based on the state of the recorder
  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(builder: (context, recorder, child) {
      if (recorder.recording)
        return _ActiveButtons();
      else
        return _PausedButtons();
    });
  }
}

class _ActiveButtons extends StatelessWidget {
  // The buttons when active
  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      leading: Icon(Icons.pause),
      child: const Text('Pause'),
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
          child: const Text('Save'),
          onPressed: () => Provider.of<_SaveState>(context, listen: false)
              .saveRecording(context),
        ),
        SizedBox(width: 10),
        RoundedButton(
          leading: Icon(Icons.play_arrow),
          child: const Text('Resume'),
          onPressed:
              Provider.of<Recorder>(context, listen: false).resumeRecording,
        ),
        SizedBox(width: 10),
        TextButton(
          child: const Text('Delete'),
          onPressed: () => Provider.of<_SaveState>(context, listen: false)
              .deleteRecording(context),
        ),
      ],
    );
  }
}
