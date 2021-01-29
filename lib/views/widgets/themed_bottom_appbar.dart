import 'package:flutter/material.dart';

class ThemedBottomAppBar extends StatelessWidget {
  final Widget child;
  final bool notched;

  ThemedBottomAppBar({@required this.child, this.notched = true});

  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: notched ? CircularNotchedRectangle() : null,
      notchMargin: -10,
      elevation: 10,
      child: Container(
        height: 55,
        child: child,
      ),
    );
  }
}

class DefaultBottomButtons extends StatelessWidget {
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () => null,
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => null,
        ),
      ],
    );
  }
}
