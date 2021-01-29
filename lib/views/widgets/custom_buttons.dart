import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  // A rounded button
  final Widget child;
  final Widget
      leading; // The widget that shows up before the child. Usually an icon.
  final Function onPressed;

  RoundedButton({
    @required this.child,
    this.onPressed,
    this.leading,
  });

  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: leading != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [leading, SizedBox(width: 10), child],
            )
          : child,
      onPressed: onPressed != null ? onPressed : () => null,
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
