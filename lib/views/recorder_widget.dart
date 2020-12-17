import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recorder.dart';
import 'package:voice_scribe/views/custom_buttons.dart';
import 'package:voice_scribe/views/duration_display.dart';

class MiniRecorderDisplay extends StatelessWidget {
  // A slim recorder display (Needs to be nested under a ChangeNotifierProvider to work)
  Widget build(BuildContext context) {
    return Consumer<Recorder>(
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
          return Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundedButton(
                child: Row(
                  children: [
                    DurationDisplay(recorder.progress),
                    const SizedBox(width: 8),
                    Icon(Icons.pause),
                  ],
                ),
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
    );
  }
}
