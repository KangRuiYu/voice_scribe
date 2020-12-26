import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/recordings_manager.dart';

class RecordingsDisplay extends StatelessWidget {
  // Widget that displays a list of recordings

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingsManager>(
      builder: (context, recordingsManager, child) {
        return ListView.builder(
          itemCount: recordingsManager.recordings.length,
          itemBuilder: (context, index) {
            return _RecordingCard(recordingsManager.recordings[index]);
          },
        );
      },
    );
  }
}

class _RecordingCard extends StatelessWidget {
  // A card that displays the information of a single recording
  final RecordingInfo _recording;

  _RecordingCard(this._recording);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 3,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _recording.name,
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 6),
            Text(
              _recording.date,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 6),
            Text(
              _recording.length.toString(),
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}
