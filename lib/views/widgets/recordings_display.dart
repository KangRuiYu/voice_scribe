import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/utils/mono_theme_constants.dart';
import 'package:voice_scribe/views/widgets/recording_card.dart';

class RecordingsDisplay extends StatelessWidget {
  // Widget that displays a list of recordings

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingsManager>(
      builder: (context, recordingsManager, child) {
        int length = recordingsManager.recordings.length + 1;
        return ListView.builder(
          itemCount: length,
          itemBuilder: (context, index) {
            if (index == length - 1)
              return SizedBox(height: PADDING_LARGE);
            else
              return Padding(
                padding: const EdgeInsets.only(
                  top: PADDING_SMALL,
                  right: PADDING_MEDIUM,
                  left: PADDING_MEDIUM,
                ),
                child: RecordingCard(recordingsManager.recordings[index]),
              );
          },
        );
      },
    );
  }
}
