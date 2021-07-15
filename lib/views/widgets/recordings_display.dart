import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/models/recording_transcriber.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/utils/mono_theme_constants.dart';
import 'package:voice_scribe/views/widgets/mono_theme_widgets.dart';
import 'package:voice_scribe/views/widgets/recording_action_popup_button.dart';
import 'package:voice_scribe/views/widgets/recording_card.dart';
import 'package:voice_scribe/views/widgets/stream_circular_progress_indicator.dart';

/// Widget that displays a list of recording cards.
class RecordingsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<RecordingsManager, RecordingTranscriber>(
      builder: (
        BuildContext context,
        RecordingsManager recordingsManager,
        RecordingTranscriber recordingTranscriber,
        Widget _,
      ) {
        int length = recordingsManager.recordings.length + 1;
        return ListView.builder(
          itemCount: length,
          itemBuilder: (context, index) {
            if (index == length - 1) {
              return SizedBox(height: PADDING_LARGE);
            } else {
              Recording recording = recordingsManager.recordings[index];
              return Padding(
                padding: const EdgeInsets.only(
                  top: PADDING_SMALL,
                  right: PADDING_MEDIUM,
                  left: PADDING_MEDIUM,
                ),
                child: RecordingCard(
                  recording: recording,
                  trailing: _DynamicTrailing(recording),
                ),
              );
            }
          },
        );
      },
    );
  }
}

/// A trailing widget for a recording card that changes dynamically.
class _DynamicTrailing extends StatelessWidget {
  final Recording _recording;

  _DynamicTrailing(Recording recording) : _recording = recording;

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingTranscriber>(
      builder: (
        BuildContext context,
        RecordingTranscriber recordingTranscriber,
        Widget _,
      ) {
        RecordingState recordingState =
            recordingTranscriber.progressOf(_recording);
        Widget cancelButton = MonoIconButton(
          iconData: Icons.cancel_rounded,
          onPressed: () => recordingTranscriber.cancel(_recording),
        );

        if (recordingState == RecordingState.notQueued) {
          return RecordingActionPopupButton(_recording);
        } else if (recordingState == RecordingState.queued) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: 0.0,
                backgroundColor: Theme.of(context).backgroundColor,
              ),
              const SizedBox(width: PADDING_SMALL),
              cancelButton,
            ],
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamCircularProgressIndicator(
                recordingTranscriber.progressStream,
              ),
              const SizedBox(width: PADDING_SMALL),
              cancelButton,
            ],
          );
        }
      },
    );
  }
}
