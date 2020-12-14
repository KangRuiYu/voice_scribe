import 'package:flutter/material.dart';
import 'views/recorder_widget.dart';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: RecorderWidget(),
        ),
      ),
    );
  }
}
