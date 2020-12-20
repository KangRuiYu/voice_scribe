import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recorder.dart';
import 'package:voice_scribe/views/widgets/recorder_widget.dart';

class RecordingScreen extends StatelessWidget {
  final Recorder _recorder = Recorder();

  RecordingScreen() {
    _recorder.startRecording();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _recorder,
      child: Scaffold(
        body: Center(
          child: RecorderWidget(),
        ),
      ),
    );
  }
}
