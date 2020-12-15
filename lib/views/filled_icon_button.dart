import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  // A circular button with an icon inside
  final IconData iconData;
  final Function onPressed;

  CircularIconButton({this.iconData, this.onPressed});

  Widget build(BuildContext context) {
    return RaisedButton(
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(12),
      child: Icon(iconData, size: 30),
      onPressed: onPressed,
    );
  }
}
