import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/utils/formatter.dart';
import 'package:voice_scribe/utils/mono_theme_constants.dart';
import 'package:voice_scribe/views/screens/playing_screen.dart';
import 'package:voice_scribe/views/widgets/mono_theme_widgets.dart';
import 'package:vosk_dart/vosk_dart.dart';

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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PlayingScreen(recording: _recording)));
  }

  void _transcribeRecording() async {
    String modelPath = join(
      (await getExternalStorageDirectory()).path,
      'vosk-model-small-en-us-0.15',
    );
    print(Directory(modelPath).existsSync());
    print(modelPath);
    Vosk transcriber = Vosk(modelPath: modelPath);
    await transcriber.open();
    transcriber.feedAudioBuffer(File(_recording.path).readAsBytesSync()).then(
      (_) async {
        print(await transcriber.close());
      },
    );
  }

  void _removeRecording(BuildContext context, bool deleteFile) {
    // Deletes the recording that this card displays
    Provider.of<RecordingsManager>(context, listen: false)
        .removeRecording(_recording, deleteSource: deleteFile);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PADDING_LARGE,
          vertical: PADDING_MEDIUM,
        ),
        title: Text(_recording.name),
        subtitle: Text(
          '${formatDate(_recording.date)}\n${formatDuration(_recording.duration)}',
        ),
        trailing: _Buttons(
          playFunc: () => playRecording(context),
          transcribeFunc: _transcribeRecording,
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

class _Buttons extends StatelessWidget {
  final Function playFunc;
  final Function transcribeFunc;
  final Function removeFunc;

  _Buttons({
    @required this.playFunc,
    @required this.transcribeFunc,
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
                value: transcribeFunc,
                child: const Text('Transcribe'),
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
