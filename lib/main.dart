import 'package:flutter/material.dart';
import 'views/recorder_widget.dart';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.amberAccent,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.amberAccent,
          colorScheme: ColorScheme.fromSwatch(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          textTheme: ButtonTextTheme.primary,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: RecorderWidget(),
        ),
      ),
    );
  }
}
