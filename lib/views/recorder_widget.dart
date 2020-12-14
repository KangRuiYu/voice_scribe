import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/recorder.dart';

class RecorderWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Recorder(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer<Recorder>(
            builder: (context, recorder, child) {
              return !recorder.recording
                  ? IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: recorder.startRecording,
                    )
                  : IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: recorder.stopRecording,
                    );
            },
          ),
        ],
      ),
    );
  }
}
