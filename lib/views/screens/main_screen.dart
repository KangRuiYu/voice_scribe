import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/views/widgets/custom_buttons.dart';
import 'package:voice_scribe/views/screens/recording_screen.dart';
import 'package:voice_scribe/views/widgets/recordings_display.dart';
import 'package:voice_scribe/models/recordings_manager.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Scribe'),
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () => null,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => null,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CircularIconButton(
        iconData: Icons.fiber_manual_record_rounded,
        onPressed: () {
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
        },
      ),
      body: RecordingsDisplay(),
    );
  }
}
