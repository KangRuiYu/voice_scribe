import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recording.dart';
import '../../models/recording_transcriber.dart';
import '../../models/recordings_manager.dart';
import 'confirmation_popup.dart';

/// Button showing a list of actions for [recording].
class RecordingActionPopupButton extends StatelessWidget {
  final Recording recording;

  const RecordingActionPopupButton(this.recording);

  void _showRemoveFilePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _RemoveFilePopup(
        removeFunc: (bool deleteFile) {
          Provider.of<RecordingsManager>(context, listen: false).remove(
            recording,
            deleteSource: deleteFile,
          );
        },
      ),
    );
  }

  void _showReTranscribePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ConfirmationPopup(
        title: const Text('Re-transcribe?'),
        content: [
          Text(
            'Transcribing this file will delete the existing transcription, even if you later cancel it.',
          ),
        ],
        onConfirm: () {
          recording.deleteTranscription();
          _transcribe(context);
        },
      ),
    );
  }

  void _transcribe(BuildContext context) {
    Provider.of<RecordingTranscriber>(context, listen: false)
        .addToQueue(recording);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void Function()>(
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (void Function() itemFunc) => itemFunc(),
      tooltip: 'More options',
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: () => _showRemoveFilePopup(context),
            child: const Text('Edit'),
          ),
          PopupMenuItem(
            value: () => recording.transcriptionExists
                ? _showReTranscribePopup(context)
                : _transcribe(context),
            child: const Text('Transcribe'),
          ),
          PopupMenuItem(
            value: () => _showRemoveFilePopup(context),
            child: const Text('Remove'),
          ),
        ];
      },
    );
  }
}

/// Popup asking user to delete a recording.
class _RemoveFilePopup extends StatefulWidget {
  final void Function(bool) _removeFunc;

  const _RemoveFilePopup({@required removeFunc}) : _removeFunc = removeFunc;

  @override
  _RemoveFilePopupState createState() => _RemoveFilePopupState();
}

class _RemoveFilePopupState extends State<_RemoveFilePopup> {
  bool _deleteFile = false;

  @override
  Widget build(BuildContext context) {
    return ConfirmationPopup(
      title: const Text('Remove?'),
      content: [
        const Text(
          'This will remove the recording from the app, but the file will still be available on the device.',
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Delete file as well'),
            Checkbox(
              value: _deleteFile,
              onChanged: (bool value) => setState(() => _deleteFile = value),
            ),
          ],
        )
      ],
      confirmationButtonLabel: 'Remove',
      onConfirm: () => widget._removeFunc(_deleteFile),
    );
  }
}
