import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/views/widgets/recording_card.dart';

class RecordingsDisplay extends StatelessWidget {
  // Widget that displays a list of recordings

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingsManager>(
      builder: (context, recordingsManager, child) {
        return ListView.builder(
          itemCount: recordingsManager.recordings.length,
          itemBuilder: (context, index) {
            return RecordingCard(recordingsManager.recordings[index]);
          },
        );
      },
    );
  }
}
