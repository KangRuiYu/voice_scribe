import 'package:flutter/material.dart';

class BottomSheetCard extends StatelessWidget {
  // A persistent bottom sheet with default styling that can hold widgets
  final Widget child;

  BottomSheetCard(this.child);

  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1)
        ],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      width: double.infinity,
      child: child,
    );
  }
}