import 'package:flutter/material.dart';

class ThemedBottomAppBar extends StatelessWidget {
  final Widget child;

  ThemedBottomAppBar({@required this.child});

  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: -10,
      elevation: 10,
      child: Container(
        height: 55,
        child: child,
      ),
    );
  }
}
