import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/utils/formatter.dart';
import 'package:voice_scribe/utils/mono_theme_constants.dart';
import 'package:voice_scribe/views/screens/playing_screen.dart';
import 'package:vosk_dart/vosk_dart.dart';

/// Displays info on a recording, allowing to perform certain actions on it.
class RecordingCard extends StatelessWidget {
  final Recording _recording;

  RecordingCard(this._recording);

  /// Asks the user for confirmation to delete the recording.
  void _askToRemoveRecording(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _RemoveConfirmationPopup(
        removeFunc: (bool deleteFile) => _removeRecording(context, deleteFile),
      ),
    );
  }

  /// Plays the recording that this card displays.
  void _playRecording(BuildContext context) {
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

    VoskInstance voskInstance = VoskInstance();
    voskInstance.progressStream.listen((var result) => print(result));
    await voskInstance.allocateSingleThread();
    await voskInstance.queueModelToBeOpened(modelPath);
    await voskInstance.queueFileForTranscription(_recording.path);
    voskInstance.close();
  }

  /// Deletes the recording that this card displays.
  void _removeRecording(BuildContext context, bool deleteFile) {
    Provider.of<RecordingsManager>(context, listen: false)
        .removeRecording(_recording, deleteSource: deleteFile);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(RADIUS),
        onTap: () => _playRecording(context),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: PADDING_LARGE,
            vertical: PADDING_MEDIUM,
          ),
          title: Text(_recording.name),
          subtitle: Text(
            '${formatDate(_recording.date)}\n${formatDuration(_recording.duration)}',
          ),
          trailing: _ActionPopupButton(
            transcribeFunc: _transcribeRecording,
            removeFunc: () => _askToRemoveRecording(context),
          ),
        ),
      ),
    );
  }
}

/// The confirmation popup that shows up before the user deletes a recording
class _RemoveConfirmationPopup extends StatefulWidget {
  final Function removeFunc;

  _RemoveConfirmationPopup({@required this.removeFunc});

  @override
  _RemoveConfirmationPopupState createState() =>
      _RemoveConfirmationPopupState();
}

class _RemoveConfirmationPopupState extends State<_RemoveConfirmationPopup> {
  bool _deleteFile = false;

  @override
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

/// Button that reveals a popup menu for a list of possible actions.
class _ActionPopupButton extends StatelessWidget {
  final Function transcribeFunc;
  final Function removeFunc;

  _ActionPopupButton({
    @required this.transcribeFunc,
    @required this.removeFunc,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
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
    );
  }
}
