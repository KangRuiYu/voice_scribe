import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recording.dart';
import '../../models/recording_transcriber.dart';
import '../../models/recordings_manager.dart';
import '../../utils/theme_constants.dart' as themeConstants;
import 'recording_action_popup_button.dart';
import '../screens/playing_screen.dart';
import '../../utils/formatter.dart' as formatter;

/// Displays the recordings in the [RecordingsManager] as a list of cards.
///
/// Has a Sliver app bar above.
/// Each card provides information and actions for a given recording.
class RecordingsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingsManager>(
      builder: (
        BuildContext context,
        RecordingsManager recordingsManager,
        Widget _,
      ) {
        return ListView.builder(
          itemCount: recordingsManager.recordings.length + 2,
          itemBuilder: (BuildContext context, int index) {
            if (index >= recordingsManager.recordings.length) {
              return const SizedBox(height: themeConstants.padding_large);
            } else {
              return _RecordingCard(recordingsManager.recordings[index]);
            }
          },
        );
      },
    );
  }
}

/// Displays info [recording] and allows it to be played.
class _RecordingCard extends StatelessWidget {
  final Recording recording;

  const _RecordingCard(this.recording);

  /// Plays the recording that this card displays.
  void _playRecording(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayingScreen(recording: recording),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingTranscriber>(
      builder: (
        BuildContext context,
        RecordingTranscriber recordingTranscriber,
        Widget _,
      ) {
        final RecordingState recordingState =
            recordingTranscriber.progressOf(recording);

        final Widget subtitle = recordingState == RecordingState.processing
            ? _StreamLinearProgressIndicator(
                recordingTranscriber.progressStream
                    .map((progress) => progress['progress']),
              )
            : Text(
                '${formatter.formatDate(recording.date)} • ${formatter.formatDuration(recording.duration)}',
              );

        final Widget trailing = recordingState == RecordingState.notQueued
            ? RecordingActionPopupButton(recording)
            : ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () => recordingTranscriber.cancel(recording),
              );

        return Card(
          margin: const EdgeInsets.only(
            top: themeConstants.padding_tiny,
            right: themeConstants.padding_medium,
            left: themeConstants.padding_medium,
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(themeConstants.radius),
            ),
            contentPadding: const EdgeInsets.only(
              left: themeConstants.padding_medium,
              right: themeConstants.padding_small,
            ),
            title: Text(recording.name),
            subtitle: subtitle,
            onTap: () => _playRecording(context),
            trailing: trailing,
          ),
        );
      },
    );
  }
}

/// Displays the progress of the given [stream] via a linear progress bar.
class _StreamLinearProgressIndicator extends StatelessWidget {
  final Stream stream;

  const _StreamLinearProgressIndicator(this.stream);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return LinearProgressIndicator(value: snapshot.data ?? 0.0);
      },
    );
  }
}
