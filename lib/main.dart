import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'views/recorder_widget.dart';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Scribe',
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.amberAccent,
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          textTheme: ButtonTextTheme.primary,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      home: Scaffold(
        body: SlidingUpPanel(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          body: Center(),
          collapsed: Center(child: RecorderWidget()),
          panel: Center(child: Text('This is the sliding widget')),
        ),
      ),
    );
  }
}
