import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recorder.dart';
import '../../models/recording.dart';
import '../../models/recordings_manager.dart';
import '../../utils/app_data.dart';
import '../../utils/theme_constants.dart' as themeConstants;
import '../widgets/duration_label.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/volume_display.dart';

class RecordingScreen extends StatelessWidget {
  final Recorder recorder = Recorder();
  final TextEditingController nameController = TextEditingController();

  Future<Recorder> _initializeRecorder(Directory recordingsDirectory) async {
    if (recorder.active) return recorder;
    await recorder.initialize();
    await recorder.startRecording(recordingsDirectory);
    return recorder;
  }

  /// Called when user presses the back button.
  ///
  /// Makes sure recorder is closed before leaving screen.
  Future<bool> onWillPop() async {
    if (recorder.active) await recorder.terminate();
    if (recorder.opened) await recorder.close();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: SafeArea(
        child: FutureBuilder(
          future: _initializeRecorder(
            context.select((AppData appData) => appData.recordingsDirectory),
          ),
          builder: (BuildContext context, AsyncSnapshot<Recorder> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Recorder recorder = snapshot.data;

              return Scaffold(
                appBar: AppBar(title: const Text('Recorder')),
                body: MultiProvider(
                  providers: [
                    ChangeNotifierProvider.value(value: recorder),
                    ChangeNotifierProvider.value(value: nameController),
                    Provider.value(value: context),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(themeConstants.padding_large),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _RecordingView(),
                        DurationLabel.recorder(
                          textStyle: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(height: themeConstants.padding_medium),
                        const _ButtonRow(),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Scaffold(
                body: const Center(child: const CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}

/// Displays different views based on the state of the recorder.
class _RecordingView extends StatelessWidget {
  const _RecordingView();

  @override
  Widget build(BuildContext context) {
    return Consumer2<Recorder, TextEditingController>(
      builder: (
        BuildContext context,
        Recorder recorder,
        TextEditingController nameController,
        Widget _,
      ) {
        if (recorder.recording) {
          return VolumeDisplay(
            stream: recorder.onProgress,
            numberOfVolumeBars: 18,
          );
        } else if (recorder.paused) {
          return Expanded(
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Recording Name',
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Displays different buttons based on the state of the recorder
class _ButtonRow extends StatelessWidget {
  const _ButtonRow();

  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(
      builder: (context, recorder, child) {
        if (recorder.recording) {
          return const _RecordingButtons();
        } else if (recorder.paused) {
          return const _PausedButtons();
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class _RecordingButtons extends StatelessWidget {
  const _RecordingButtons();

  @override
  Widget build(BuildContext context) {
    return CircularIconButton(
      iconData: Icons.pause_rounded,
      onPressed: context.select((Recorder recorder) => recorder.pauseRecording),
    );
  }
}

/// The buttons when paused
class _PausedButtons extends StatelessWidget {
  const _PausedButtons();

  Future<void> onSave(BuildContext context) async {
    Recorder recorder = context.read<Recorder>();
    TextEditingController nameController =
        context.read<TextEditingController>();
    RecordingsManager recordingsManager = context.read<RecordingsManager>();
    BuildContext mainContext = context.read<BuildContext>();

    Recording recording = await recorder.stopRecording(nameController.text);
    await recorder.close();
    recordingsManager.add(recording);
    Navigator.pop(mainContext);
  }

  Future<void> onDelete(BuildContext context) async {
    Recorder recorder = context.read<Recorder>();
    BuildContext mainContext = context.read<BuildContext>();

    await recorder.terminate();
    await recorder.close();
    Navigator.pop(mainContext);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: const Text('Save'),
          onPressed: () => onSave(context),
        ),
        const SizedBox(width: themeConstants.padding_medium),
        CircularIconButton(
          iconData: Icons.play_arrow_rounded,
          onPressed: context.select(
            (Recorder recorder) => recorder.resumeRecording,
          ),
        ),
        const SizedBox(width: themeConstants.padding_medium),
        TextButton(
          child: const Text('Delete'),
          onPressed: () => onDelete(context),
        ),
      ],
    );
  }
}
