import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/models/recording_transcriber.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/views/widgets/confirmation_popup.dart';

/// Button showing list of actions for a given recording.
class RecordingActionPopupButton extends StatelessWidget {
  final Recording _recording;

  RecordingActionPopupButton(this._recording);

  void _showRemoveFilePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _RemoveFilePopup(
        removeFunc: (bool deleteFile) {
          Provider.of<RecordingsManager>(context, listen: false)
              .removeRecording(
            _recording,
            deleteSource: deleteFile,
          );
        },
      ),
    );
  }

  void _transcribe(BuildContext context) {
    Provider.of<RecordingTranscriber>(context, listen: false)
        .addToQueue(_recording);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      onSelected: (Function itemFunc) => itemFunc(),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: () => _showRemoveFilePopup(context),
            child: const Text('Edit'),
          ),
          PopupMenuItem(
            value: () => _transcribe(context),
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

/// The confirmation popup that shows up before the user deletes a recording
class _RemoveFilePopup extends StatefulWidget {
  final void Function(bool) _removeFunc;

  _RemoveFilePopup({@required removeFunc}) : _removeFunc = removeFunc;

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
