import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vosk_dart/transcript_event.dart';
import 'package:tuple/tuple.dart';

import 'package:voice_scribe/constants/file_extensions.dart' as file_extensions;
import 'package:voice_scribe/constants/theme_constants.dart' as theme_constants;
import 'package:voice_scribe/models/app_dir.dart';
import 'package:voice_scribe/models/audio/recorder.dart';
import 'package:voice_scribe/models/audio/recording.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/models/transcript/stream_transcriber.dart';
import 'package:voice_scribe/models/transcript/transcript_event_provider.dart';
import 'package:voice_scribe/utils/file_utils.dart' as file_utils;
import 'package:voice_scribe/utils/formatter.dart' as formatter;
import 'package:voice_scribe/views/widgets/custom_widgets.dart';
import 'package:voice_scribe/views/widgets/transcript_result.dart';

class RecordingScreen extends StatelessWidget {
  final Recorder recorder = Recorder();
  final TranscriptEventProvider transcriptEventProvider =
      TranscriptEventProvider();
  final TextEditingController nameController = TextEditingController();

  /// Initialize both [recorder], [StreamTranscriber] and
  /// [transcriptEventProvider] for use.
  Future<void> _init({
    @required AppDirs appDirs,
    @required StreamTranscriber streamTranscriber,
  }) async {
    if (recorder.active) return;

    Uuid uuid = Uuid();
    File tempRecordingFile = file_utils.fileIn(
      parentDirectory: appDirs.tempDirectory,
      name: uuid.v1(),
      extension: file_extensions.temp,
    );
    File tempTranscriptFile = file_utils.fileIn(
      parentDirectory: appDirs.tempDirectory,
      name: uuid.v1(),
      extension: file_extensions.temp,
    );

    await recorder.initialize();
    await recorder.startRecording(tempRecordingFile.path);

    await streamTranscriber.initialize();
    await streamTranscriber.start(
      audioStream: recorder.audioStream,
      tempLocation: tempTranscriptFile.path,
    );
    await transcriptEventProvider.initialize({
      'eventStream': streamTranscriber.eventStream,
    });
  }

  // Generates a unique name based on the current time (down to the second) used
  // for recordings without a defined name.
  String _generateTimeString() {
    DateTime date = DateTime.now();
    return '${date.month}-${date.day}-${date.year}' +
        '-${date.hour}-${date.minute}-${date.second}';
  }

  @override
  Widget build(BuildContext context) {
    final AppDirs appDirs = context.watch<AppDirs>();

    final StreamTranscriber streamTranscriber =
        context.watch<StreamTranscriber>();

    // Dynamically created exit function.
    final Future<bool> Function() onExit = () async {
      if (streamTranscriber.active) await streamTranscriber.stop();
      if (recorder.active) await recorder.terminate();
      if (recorder.opened) await recorder.close();
      return true;
    };

    // Dynamically created save function.
    final Future<void> Function() onSave = () async {
      // Get/Create source directory.
      Directory recordingSourceDir = file_utils.directoryIn(
        parentDirectory: appDirs.recordingsDirectory,
        name: nameController.text.isNotEmpty
            ? nameController.text
            : _generateTimeString(),
      );
      await recordingSourceDir.create();

      // Create recording.
      Recording recording = Recording(sourceDirectory: recordingSourceDir);

      // Save duration and audio file.
      recording.duration = await recorder.stopRecording(
        recording.audioFile.path,
      );
      await recorder.close();

      // Save transcript file.
      await streamTranscriber.finish(
        recording.transcriptFile.path,
      );

      // Write metadata.
      recording.writeMetadata();

      context.read<RecordingsManager>().add(recording);

      Navigator.pop(context);
    };

    return WillPopScope(
      onWillPop: onExit,
      child: FutureBuilder(
        future: _init(appDirs: appDirs, streamTranscriber: streamTranscriber),
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
              ChangeNotifierProvider.value(value: transcriptEventProvider),
              ChangeNotifierProvider.value(value: nameController),
              Provider<Future<void> Function()>.value(value: onSave),
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
          return _TranscriptResultList();
        } else if (recorder.paused) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: theme_constants.padding_medium,
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

/// Displays a list of the current transcript results.
class _TranscriptResultList extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  /// True if list can't scroll or at the bottom edge of the list.
  bool _atBottomEdge() {
    if (!_scrollController.position.hasContentDimensions ||
        !_scrollController.position.hasPixels) {
      return true;
    }

    return _scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent;
  }

  /// Scrolls the list to the very bottom once build finishes.
  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (Duration timeStamp) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Selector(
        shouldRebuild: (previous, next) => previous.item1 != next.item1,
        selector: (BuildContext ctx, TranscriptEventProvider t) =>
            Tuple2(t.resultCount, t.resultEvents),
        builder: (
          BuildContext context,
          Tuple2<int, UnmodifiableListView<TranscriptEvent>> data,
          Widget _,
        ) {
          final UnmodifiableListView<TranscriptEvent> resultEvents = data.item2;

          return ListView.builder(
            controller: _scrollController,
            itemCount: resultEvents.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index < resultEvents.length) {
                TranscriptEvent event = resultEvents[index];
                return TranscriptResult(
                  timestamp: event.timestamp,
                  resultText: event.text,
                );
              } else {
                return Selector(
                  selector: (BuildContext ctx, TranscriptEventProvider t) {
                    return t.partialEvent;
                  },
                  builder: (
                    BuildContext ctx,
                    TranscriptEvent event,
                    Widget _,
                  ) {
                    // Scroll to bottom at every partial update.
                    if (_atBottomEdge()) {
                      _scrollToBottom();
                    }

                    return TranscriptResult(resultText: event.text);
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

/// The bottom panel containing indicators and controls for the [Recorder].
class _BottomPanel extends StatelessWidget {
  const _BottomPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(theme_constants.padding_large),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: kElevationToShadow[theme_constants.elevation],
      ),
      child: Column(
        children: [
          const _InfoLine(),
          const SizedBox(height: theme_constants.padding_medium),
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
              const SizedBox(width: theme_constants.padding_small),
              Expanded(child: _VolumeIndicator(snapshot.data.decibels)),
              const SizedBox(width: theme_constants.padding_huge),
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
    final Color inactiveColor = activeColor.withAlpha(theme_constants.opacity);

    final double activePercentage = decibels.clamp(0, max_volume) / max_volume;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            Container(
              height: theme_constants.bar_height,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: inactiveColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            AnimatedContainer(
              height: theme_constants.bar_height,
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
                onPressed: context.watch<Future<void> Function()>(),
              ),
            ],
          ),
        ),
        const SizedBox(width: theme_constants.padding_medium),
        CircularIconButton(
          iconData: Icons.play_arrow_rounded,
          onPressed: context.select(
            (Recorder recorder) => recorder.resumeRecording,
          ),
        ),
        const SizedBox(width: theme_constants.padding_medium),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text('Delete'),
                onPressed: () => Navigator.maybePop(context),
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
  }
}
