import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/recording_transcriber.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/utils/file_utils.dart';
import 'package:voice_scribe/views/screens/main_screen.dart';
import 'package:voice_scribe/utils/main_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  createDirectories().then(
    (_) => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RecordingsManager()),
          ChangeNotifierProvider(create: (_) => RecordingTranscriber()),
        ],
        child: VoiceScribe(),
      ),
    ),
  );
}

/// The main app.
class VoiceScribe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Scribe',
      theme: mainTheme,
      home: MainScreen(),
    );
  }
}
