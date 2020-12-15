import 'package:flutter/material.dart';
import 'package:voice_scribe/views/bottom_sheet_card.dart';
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
        body: Center(
        ),
        bottomSheet: BottomSheetCard(RecorderWidget()),
      ),
    );
  }
}
