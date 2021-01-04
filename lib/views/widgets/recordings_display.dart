import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/views/screens/playing_screen.dart';

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

  void _askUserToDeleteRecording(BuildContext context) {
    // Asks the user for confirmation to delete the recording
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    'This action is irreversible and the deleted recording will be lost forever.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteRecording(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteRecording(BuildContext context) {
    // Deletes the recording that this card displays
    Provider.of<RecordingsManager>(context, listen: false)
        .deleteRecording(_recording);
  }

  void _playRecording(BuildContext context) {
    // Plays the recording that this card displays
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PlayingScreen(_recording)));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 3,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          _recording.name,
          style: Theme.of(context).textTheme.headline6,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _recording.date,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            SizedBox(height: 6),
            Text(
              _recording.length.toString(),
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () => _playRecording(context),
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    child: Text('Delete'),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
