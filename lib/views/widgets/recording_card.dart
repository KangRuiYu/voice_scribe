import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/utils/formatter.dart';

import 'package:voice_scribe/models/recordings_manager.dart';

import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/views/screens/playing_screen.dart';

class RecordingCard extends StatelessWidget {
  // A card that displays the information of a single recording and common controls
  final Recording _recording;

  RecordingCard(this._recording);

  void askToRemoveRecording(BuildContext context) {
    // Asks the user for confirmation to delete the recording
    showDialog(
      context: context,
      builder: (BuildContext context) => RemoveConfirmationPopup(
        removeFunc: (bool deleteFile) => _removeRecording(context, deleteFile),
      ),
    );
  }

  void playRecording(BuildContext context) {
    // Plays the recording that this card displays
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PlayingScreen(_recording)));
  }

  void _removeRecording(BuildContext context, bool deleteFile) {
    // Deletes the recording that this card displays
    Provider.of<RecordingsManager>(context, listen: false)
        .removeRecording(_recording, deleteSource: deleteFile);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 3,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: _Title(_recording.name),
        subtitle: _Details(
          date: _recording.date,
          duration: _recording.duration,
        ),
        trailing: _Buttons(
          playFunc: () => playRecording(context),
          removeFunc: () => askToRemoveRecording(context),
        ),
      ),
    );
  }
}

class RemoveConfirmationPopup extends StatefulWidget {
  // The confirmation popup that shows up before the user deletes a recording
  final Function removeFunc;

  RemoveConfirmationPopup({@required this.removeFunc});

  _RemoveConfirmationPopupState createState() =>
      _RemoveConfirmationPopupState();
}

class _RemoveConfirmationPopupState extends State<RemoveConfirmationPopup> {
  bool _deleteFile = false;

  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remove?'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            const Text(
              'This will remove the recording from the app, but the file will still be available on the device.',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Delete file as well'),
                Checkbox(
                  value: _deleteFile,
                  onChanged: (bool value) {
                    setState(() => _deleteFile = value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Remove'),
          onPressed: () {
            widget.removeFunc(_deleteFile);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  // The title of the card
  final String _title;

  _Title(this._title);

  @override
  Widget build(BuildContext context) {
    return Text(
      _title,
      style: Theme.of(context).textTheme.bodyText1,
    );
  }
}

class _Details extends StatelessWidget {
  // The sub details like date and duration
  final DateTime date;
  final Duration duration;

  _Details({
    @required this.date,
    @required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatDate(date),
          style: Theme.of(context).textTheme.caption,
        ),
        SizedBox(height: 6),
        Text(
          formatDuration(duration),
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
}

class _Buttons extends StatelessWidget {
  final Function playFunc;
  final Function removeFunc;

  _Buttons({
    @required this.playFunc,
    @required this.removeFunc,
  });

  // The buttons on the card
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: playFunc,
        ),
        PopupMenuButton(
          icon: Icon(Icons.more_vert),
          onSelected: (Function itemFunc) => itemFunc(),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: removeFunc,
                child: const Text('Edit'),
              ),
              PopupMenuItem(
                value: removeFunc,
                child: const Text('Remove'),
              ),
            ];
          },
        ),
      ],
    );
  }
}
