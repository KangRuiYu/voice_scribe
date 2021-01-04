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
          appBarTheme: AppBarTheme(
            color: Colors.white,
            textTheme: Theme.of(context).textTheme,
            elevation: 1,
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.black54,
            ),
          ),
          primarySwatch: Colors.red,
          accentColor: Colors.black12,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonTheme: ButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        home: MainScreen(),
      ),
    );
  }
}
