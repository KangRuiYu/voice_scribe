import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/recorder.dart';

class RecorderWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Recorder(),
      child: Consumer<Recorder>(
        builder: (context, recorder, child) {
          if (recorder.paused) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: recorder.stopRecording,
                ),
                RaisedButton(
                  child: Text('Resume'),
                  onPressed: recorder.resumeRecording,
                ),
              ],
            );
          } else if (recorder.recording) {
            return IconButton(
              icon: Icon(Icons.pause),
              onPressed: recorder.pauseRecording,
            );
          } else {
            return IconButton(
              icon: Icon(Icons.fiber_manual_record_rounded),
              onPressed: recorder.startRecording,
            );
          }
        },
      ),
    );
  }
}
