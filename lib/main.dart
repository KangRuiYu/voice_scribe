import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/recording.dart';
import 'models/recording_transcriber.dart';
import 'models/recordings_manager.dart';
import 'utils/asset_utils.dart' as assets;
import 'utils/main_theme.dart';
import 'views/screens/main_screen.dart';

void main() {
  startVoiceScribe();
}

Future<void> startVoiceScribe() async {
  WidgetsFlutterBinding.ensureInitialized();

  Map<String, Directory> directories = await assets.createDirectories();

  RecordingsManager recordingsManager = RecordingsManager.autoLoad(
    recordingsDirectory: directories['recordingsDirectory'],
    metadataDirectory: directories['metadataDirectory'],
  );
  RecordingTranscriber recordingTranscriber = RecordingTranscriber(
    transcriptionDirectory: directories['transcriptionDirectory'],
    onDone: (Recording recording) => recordingsManager.saveMetadata(recording),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: recordingsManager),
        ChangeNotifierProvider.value(value: recordingTranscriber),
      ],
      child: VoiceScribe(),
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
