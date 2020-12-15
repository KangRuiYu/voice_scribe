import 'package:flutter/material.dart';

class FilledIconButton extends StatelessWidget {
  // An icon button with a filled background
  final Icon icon;
  final Function onPressed;

  FilledIconButton({this.icon, this.onPressed});

  Widget build(BuildContext context) {
    return Ink(
      decoration: ShapeDecoration(
        color: Theme.of(context).accentColor,
        shape: const CircleBorder(),
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}
