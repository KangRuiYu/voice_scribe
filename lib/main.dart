import 'package:flutter/material.dart';
import 'package:voice_scribe/views/screens/main_screen.dart';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Scribe',
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.black12,
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
      home: MainScreen(),
    );
  }
}
