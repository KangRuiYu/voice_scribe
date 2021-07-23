import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recorder.dart';
import '../../models/recording.dart';
import '../../models/recordings_manager.dart';
import '../../utils/mono_theme_constants.dart';
import '../widgets/duration_label.dart';
import '../widgets/mono_theme_widgets.dart';
import '../widgets/volume_display.dart';
import '../../utils/asset_utils.dart' as assets;

class _SaveState extends ChangeNotifier {
  // The saving state (the name inputted and saving functions)
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController get textEditingController => _textEditingController;

  void saveRecording(BuildContext context) async {
    // Save recording and return to previous screen
    Recording recording = await Provider.of<Recorder>(context, listen: false)
        .stopRecording(_textEditingController.text);
    Provider.of<RecordingsManager>(context, listen: false).add(recording);
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
  Recorder _recorder;

  Future<Recorder> _initializeRecorder() async {
    _recorder = Recorder(await assets.recordingsDirectory());
    await _recorder.initialize();
    await _recorder.startRecording();
    return _recorder;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_recorder.active) await _recorder.terminate();
        if (_recorder.opened) await _recorder.close();
        return true;
      },
      child: FutureBuilder(
        future: _initializeRecorder(),
        builder: (BuildContext context, AsyncSnapshot<Recorder> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: snapshot.data),
                ChangeNotifierProvider(create: (_) => _SaveState()),
              ],
              child: FreeScaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RecordingView(),
                    DurationLabel.recorder(
                      textStyle: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(height: PADDING_MEDIUM),
                    _Buttons(),
                  ],
                ),
              ),
            );
          } else {
            return FreeScaffold(
              loading: true,
            );
          }
        },
      ),
    );
  }
}

class _RecordingView extends StatelessWidget {
  // Displays different views based on the state of the recorder
  @override
  Widget build(BuildContext context) {
    _SaveState saveState = Provider.of<_SaveState>(context, listen: false);
    return Consumer<Recorder>(
      builder: (context, recorder, child) {
        if (recorder.paused) {
          // While paused
          return Expanded(
            child: TextField(
              controller: saveState.textEditingController,
              decoration: InputDecoration(
                labelText: 'Recording Name',
              ),
            ),
          );
        } else {
          // While recording
          return VolumeDisplay(
            stream: recorder.onProgress,
            numberOfVolumeBars: 18,
          );
        }
      },
    );
  }
}

class _Buttons extends StatelessWidget {
  // Displays different buttons based on the state of the recorder
  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(builder: (context, recorder, child) {
      if (recorder.paused)
        return _PausedButtons();
      else
        return _ActiveButtons();
    });
  }
}

class _ActiveButtons extends StatelessWidget {
  // The buttons when active
  @override
  Widget build(BuildContext context) {
    return CircularIconButton(
      iconData: Icons.pause_rounded,
      onPressed: Provider.of<Recorder>(context, listen: false).pauseRecording,
    );
  }
}

class _PausedButtons extends StatelessWidget {
  // The buttons when paused
  @override
  Widget build(BuildContext context) {
    _SaveState saveState = Provider.of<_SaveState>(context, listen: false);
    Recorder recorder = Provider.of<Recorder>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: const Text('Save'),
          onPressed: () => saveState.saveRecording(context),
        ),
        const SizedBox(width: PADDING_MEDIUM),
        CircularIconButton(
          iconData: Icons.play_arrow_rounded,
          onPressed: recorder.resumeRecording,
        ),
        const SizedBox(width: PADDING_MEDIUM),
        TextButton(
          child: const Text('Delete'),
          onPressed: () => saveState.deleteRecording(context),
        ),
      ],
    );
  }
}
