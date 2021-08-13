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

  /// Initializes values.
  ///
  /// Starts the recorder. If already started, immediately returns.
  Future<void> _init(Directory recordingsDirectory) async {
    if (recorder.active) return;
    await recorder.initialize();
    await recorder.startRecording(recordingsDirectory);
  }

  /// Called when user presses the back button.
  ///
  /// Makes sure recorder is closed before leaving screen.
  Future<bool> _onExit() async {
    if (recorder.active) await recorder.terminate();
    if (recorder.opened) await recorder.close();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Directory recordingsDirectory = context.select(
      (AppData appData) => appData.recordingsDirectory,
    );

    // Dynamically created save function.
    final Future<void> Function() onSave = () async {
      Recording recording = await recorder.stopRecording(nameController.text);
      await recorder.close();
      context.read<RecordingsManager>().add(recording);
      Navigator.pop(context);
    };

    // Dynamically created delete function.
    final Future<void> Function() onDelete = () async {
      await recorder.terminate();
      await recorder.close();
      Navigator.pop(context);
    };

    return WillPopScope(
      onWillPop: _onExit,
      child: FutureBuilder(
        future: _init(recordingsDirectory),
        builder: (BuildContext _, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: recorder),
                ChangeNotifierProvider.value(value: nameController),
                Provider.value(value: {'onSave': onSave, 'onDelete': onDelete}),
              ],
              child: const _RecordingScreenScaffold(),
            );
          } else {
            return const LoadingScaffold();
          }
        },
      ),
    );
  }
}

/// The main scaffold for the recording screen.
class _RecordingScreenScaffold extends StatelessWidget {
  const _RecordingScreenScaffold();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Recorder')),
        body: Padding(
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
  }
}

/// The main content. Changed depending on the state of the [Recorder].
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

/// Row of buttons that controls the [Recorder]. Changes based on its state.
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

/// Buttons shown when the [Recorder] is active.
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

/// Buttons shown when the [Recorder] is paused.
class _PausedButtons extends StatelessWidget {
  const _PausedButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: const Text('Save'),
          onPressed: context.select(
            (Map<String, Future<void> Function()> functions) =>
                functions['onSave'],
          ),
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
          onPressed: context.select(
            (Map<String, Future<void> Function()> functions) =>
                functions['onDelete'],
          ),
        ),
      ],
    );
  }
}
