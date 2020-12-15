import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recorder.dart';
import 'package:voice_scribe/views/filled_icon_button.dart';
import 'package:voice_scribe/views/duration_display.dart';

class RecorderWidget extends StatelessWidget {
  // A widget for recording sound through the microphone
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Recorder(),
      child: Consumer<Recorder>(
        builder: (context, recorder, child) {
          if (recorder.paused) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularIconButton(
                  iconData: Icons.stop,
                  onPressed: recorder.stopRecording,
                ),
                CircularIconButton(
                  iconData: Icons.play_arrow,
                  onPressed: recorder.resumeRecording,
                ),
              ],
            );
          } else if (recorder.recording) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DurationDisplay(recorder.progress),
                const SizedBox(height: 15),
                CircularIconButton(
                  iconData: Icons.pause,
                  onPressed: recorder.pauseRecording,
                ),
              ],
            );
          } else {
            return CircularIconButton(
              iconData: Icons.fiber_manual_record_rounded,
              onPressed: recorder.startRecording,
            );
          }
        },
      ),
    );
  }
}
