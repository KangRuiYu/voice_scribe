import 'package:flutter/material.dart';
import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/utils/formatter.dart';
import 'package:voice_scribe/utils/mono_theme_constants.dart';
import 'package:voice_scribe/views/screens/playing_screen.dart';

/// Displays info on a recording and allows it to be played.
class RecordingCard extends StatelessWidget {
  final Recording _recording;
  final Widget _trailing;

  RecordingCard({@required recording, trailing})
      : _recording = recording,
        _trailing = trailing;

  /// Plays the recording that this card displays.
  void _playRecording(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayingScreen(recording: _recording),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(RADIUS),
        onTap: () => _playRecording(context),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: PADDING_LARGE,
            vertical: PADDING_MEDIUM,
          ),
          title: Text(_recording.name),
          subtitle: Text(
            '${formatDate(_recording.date)}\n${formatDuration(_recording.duration)}',
          ),
          trailing: _trailing,
        ),
      ),
    );
  }
}
