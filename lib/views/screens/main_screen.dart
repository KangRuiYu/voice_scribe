import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/views/widgets/themed_bottom_appbar.dart';
import 'package:voice_scribe/views/widgets/custom_buttons.dart';
import 'package:voice_scribe/views/screens/recording_screen.dart';
import 'package:voice_scribe/views/widgets/recordings_display.dart';
import 'package:voice_scribe/models/recordings_manager.dart';

class MainScreen extends StatelessWidget {
  void startRecording(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider.value(
            value: Provider.of<RecordingsManager>(context, listen: false),
            child: RecordingScreen(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recordings'),
          actions: [
            IconButton(
              icon: Icon(
                Provider.of<RecordingsManager>(context, listen: true)
                        .sortReversed
                    ? Icons.arrow_upward_outlined
                    : Icons.arrow_downward_outlined,
              ),
              onPressed: Provider.of<RecordingsManager>(
                context,
                listen: false,
              ).reverseSort,
            ),
          ],
        ),
        bottomNavigationBar: ThemedBottomAppBar(
          child: DefaultBottomButtons(),
          notched: false,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: RoundedButton(
          leading: Icon(Icons.fiber_manual_record_rounded),
          child: const Text('Record'),
          onPressed: () => startRecording(context),
        ),
        body: RecordingsDisplay(),
      ),
    );
  }
}
