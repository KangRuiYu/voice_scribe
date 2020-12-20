import 'package:flutter/material.dart';
import 'package:voice_scribe/views/main_Screen.dart';

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
        textTheme: TextTheme(
          bodyText1: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          bodyText2: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
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

