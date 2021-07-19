import 'package:flutter/material.dart';

/// A popup that asks to choose between a 'Cancel' or 'Confirm' option.
class ConfirmationPopup extends StatelessWidget {
  final Widget _title;
  final List<Widget> _content;
  final void Function() _onConfirm;
  final String _confirmationButtonLabel;
  final String _cancelButtonLabel;

  const ConfirmationPopup({
    @required Widget title,
    @required List<Widget> content,
    @required void Function() onConfirm,
    String confirmationButtonLabel = 'Confirm',
    String cancelButtonLabel = 'Cancel',
  })  : _title = title,
        _content = content,
        _onConfirm = onConfirm,
        _confirmationButtonLabel = confirmationButtonLabel,
        _cancelButtonLabel = cancelButtonLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _title,
      content: SingleChildScrollView(
        child: ListBody(
          children: _content,
        ),
      ),
      actions: [
        TextButton(
          child: Text(_cancelButtonLabel),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(_confirmationButtonLabel),
          onPressed: () {
            _onConfirm();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
