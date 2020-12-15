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
                FilledIconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: recorder.stopRecording,
                ),
                SizedBox(width: 10),
                FilledIconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: recorder.resumeRecording,
                ),
              ],
            );
          } else if (recorder.recording) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DurationDisplay(recorder.progress),
                SizedBox(height: 10),
                FilledIconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: recorder.pauseRecording,
                ),
              ],
            );
          } else {
            return FilledIconButton(
              icon: const Icon(Icons.fiber_manual_record_rounded),
              onPressed: recorder.startRecording,
            );
          }
        },
      ),
    );
  }
}
