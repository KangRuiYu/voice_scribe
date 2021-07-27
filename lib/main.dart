import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/recording.dart';
import 'models/recording_transcriber.dart';
import 'models/recordings_manager.dart';
import 'utils/app_data.dart';
import 'utils/main_theme.dart';
import 'views/screens/main_screen.dart';

void main() {
  startVoiceScribe();
}

Future<void> startVoiceScribe() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppData appData = AppData(
    recordingsDirectory: await recordingsDirectory(),
    metadataDirectory: await metadataDirectory(),
    modelsDirectory: await modelsDirectory(),
    transcriptionsDirectory: await transcriptionDirectory(),
  );

  RecordingsManager recordingsManager = RecordingsManager.autoLoad(
    recordingsDirectory: appData.recordingsDirectory,
    metadataDirectory: appData.metadataDirectory,
  );
  RecordingTranscriber recordingTranscriber = RecordingTranscriber(
    transcriptionDirectory: appData.transcriptionsDirectory,
    onDone: (Recording recording) => recordingsManager.saveMetadata(recording),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: appData),
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
