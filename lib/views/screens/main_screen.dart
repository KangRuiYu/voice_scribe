import 'package:flutter/material.dart';

import 'package:voice_scribe/views/widgets/custom_buttons.dart';
import 'package:voice_scribe/views/screens/recording_screen.dart';
import 'package:voice_scribe/views/widgets/recordings_display.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CircularIconButton(
        iconData: Icons.fiber_manual_record_rounded,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecordingScreen()),
          );
        },
      ),
      body: RecordingsDisplay(),
    );
  }
}
