import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/views/screens/main_screen.dart';
import 'package:voice_scribe/models/recordings_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(VoiceScribe());
}

class VoiceScribe extends StatelessWidget {
  // The main app
  final RecordingsManager _recordingsManager = RecordingsManager();

  VoiceScribe() {
    _recordingsManager.loadRecordings();
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _recordingsManager,
      child: MaterialApp(
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
      ),
    );
  }
}
