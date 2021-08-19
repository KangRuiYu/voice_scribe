import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:provider/provider.dart';

import '../../models/recorder.dart';
import '../../models/recording.dart';
import '../../models/recordings_manager.dart';
import '../../utils/app_data.dart';
import '../../utils/formatter.dart' as formatter;
import '../../utils/theme_constants.dart' as themeConstants;
import '../widgets/custom_widgets.dart';

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
          Widget body;

          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            body = Column(
              children: [
                const _ContentView(),
                const _BottomPanel(),
              ],
            );
          } else {
            body = const Center(child: const CircularProgressIndicator());
          }

          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: recorder),
              ChangeNotifierProvider.value(value: nameController),
              Provider.value(value: {'onSave': onSave, 'onDelete': onDelete}),
            ],
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(title: const Text('Recorder')),
                body: body,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Dynamically displays content based on [Recorder] state.
class _ContentView extends StatelessWidget {
  const _ContentView();

  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(
      builder: (BuildContext context, Recorder recorder, Widget _) {
        if (recorder.recording) {
          return const Expanded(child: const SizedBox.shrink());
        } else if (recorder.paused) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: themeConstants.padding_medium,
              ),
              child: TextField(
                controller: context.watch<TextEditingController>(),
                decoration: const InputDecoration(labelText: 'Recording Name'),
              ),
            ),
          );
        } else {
          return const Expanded(
            child: const Center(child: const CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

/// The bottom panel containing indicators and controls for the [Recorder].
class _BottomPanel extends StatelessWidget {
  const _BottomPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(themeConstants.padding_large),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: kElevationToShadow[themeConstants.elevation],
      ),
      child: Column(
        children: [
          const _InfoLine(),
          const SizedBox(height: themeConstants.padding_medium),
          const _ButtonRow(),
        ],
      ),
    );
  }
}

/// Displays info on the current [Recorder] such as duration and volume.
class _InfoLine extends StatelessWidget {
  const _InfoLine();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: RecordingDisposition.zero(),
      stream: context.select((Recorder recorder) => recorder.onProgress),
      builder: (
        BuildContext context,
        AsyncSnapshot<RecordingDisposition> snapshot,
      ) {
        if (snapshot.hasData && !snapshot.hasError) {
          return Row(
            children: [
              _VolumeLabel(snapshot.data.decibels),
              const SizedBox(width: themeConstants.padding_small),
              Expanded(child: _VolumeIndicator(snapshot.data.decibels)),
              const SizedBox(width: themeConstants.padding_huge),
              _DurationLabel(snapshot.data.duration),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Displays duration of the current [Recorder].
class _DurationLabel extends StatelessWidget {
  final Duration duration;

  const _DurationLabel(this.duration);

  @override
  Widget build(BuildContext context) {
    return Text(
      formatter.formatDuration(duration),
      style: Theme.of(context).textTheme.subtitle1,
    );
  }
}

/// Text label displaying the [Recorder] volume.
class _VolumeLabel extends StatelessWidget {
  final double decibels;

  const _VolumeLabel(this.decibels);

  @override
  Widget build(BuildContext context) {
    return Text(
      decibels.toStringAsFixed(0).padLeft(2, ' ') + ' dB',
      style: Theme.of(context).textTheme.subtitle1,
    );
  }
}

/// Visual bar displaying the current volume of [Recorder].
class _VolumeIndicator extends StatelessWidget {
  static const max_volume = 80;

  final double decibels;

  const _VolumeIndicator(this.decibels);

  @override
  Widget build(BuildContext context) {
    final ColorScheme mainColorScheme = Theme.of(context).colorScheme;
    final Color activeColor = mainColorScheme.secondary;
    final Color inactiveColor = activeColor.withAlpha(themeConstants.opacity);

    final double activePercentage = decibels.clamp(0, max_volume) / max_volume;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            Container(
              height: themeConstants.bar_height,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: inactiveColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            AnimatedContainer(
              height: themeConstants.bar_height,
              width: constraints.maxWidth * activePercentage,
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow();

  @override
  Widget build(BuildContext context) {
    return Consumer<Recorder>(
      builder: (BuildContext context, Recorder recorder, Widget _) {
        if (recorder.recording) {
          return _RecordingButtons();
        } else if (recorder.paused) {
          return _PausedButtons();
        } else {
          return _InactiveButtons();
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
    // return Stack(
    //   alignment: Alignment.center,
    //   children: [
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         TextButton(
    //           child: const Text('Save'),
    //           onPressed: context.select(
    //             (Map<String, Future<void> Function()> functions) =>
    //                 functions['onSave'],
    //           ),
    //         ),
    //         SizedBox(width: 100),
    //         TextButton(
    //           child: const Text('Delete'),
    //           onPressed: context.select(
    //             (Map<String, Future<void> Function()> functions) =>
    //                 functions['onDelete'],
    //           ),
    //         ),
    //       ],
    //     ),
    //     CircularIconButton(
    //       iconData: Icons.play_arrow_rounded,
    //       onPressed: context.select(
    //         (Recorder recorder) => recorder.resumeRecording,
    //       ),
    //     ),
    //   ],
    // );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text('Save'),
                onPressed: context.select(
                  (Map<String, Future<void> Function()> functions) =>
                      functions['onSave'],
                ),
              ),
            ],
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
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text('Delete'),
                onPressed: context.select(
                  (Map<String, Future<void> Function()> functions) =>
                      functions['onDelete'],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Button shown when [Recorder] is inactive. The same buttons as when paused
/// without any functionality.
class _InactiveButtons extends StatelessWidget {
  const _InactiveButtons();

  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            TextButton(
              child: const Text('Save'),
              onPressed: () => null,
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => null,
            ),
          ],
        ),
        CircularIconButton(
          iconData: Icons.play_arrow_rounded,
          onPressed: () => null,
        ),
      ],
    );
    return Row(
      children: [
        TextButton(
          child: const Text('Save'),
          onPressed: () => null,
        ),
        const SizedBox(width: themeConstants.padding_medium),
        CircularIconButton(
          iconData: Icons.play_arrow_rounded,
          onPressed: () => null,
        ),
        const SizedBox(width: themeConstants.padding_medium),
        TextButton(
          child: const Text('Delete'),
          onPressed: () => null,
        ),
      ],
    );
  }
}
