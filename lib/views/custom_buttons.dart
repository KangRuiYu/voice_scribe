import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  // A rounded button
  final Widget child;
  final Function onPressed;

  RoundedButton({this.child, this.onPressed});

  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      padding: const EdgeInsets.all(16),
      child: child,
      onPressed: onPressed,
    );
  }
}

class CircularIconButton extends StatelessWidget {
  // A circular icon button
  final IconData iconData;
  final Function onPressed;

  CircularIconButton({this.iconData, this.onPressed});

  Widget build(BuildContext context) {
    return RaisedButton(
      shape: CircleBorder(),
      padding: const EdgeInsets.all(12),
      child: Icon(iconData, size: 30),
      onPressed: onPressed,
    );
  }
}
