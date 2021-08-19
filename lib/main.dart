import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/recording.dart';
import 'models/recording_transcriber.dart';
import 'models/recordings_manager.dart';
import 'utils/app_data.dart';
import 'utils/theme_constants.dart' as themeConstants;
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
    final ColorScheme mainColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.red,
      brightness: Brightness.light,
      accentColor: Colors.redAccent,
      backgroundColor: Colors.grey.shade50,
      cardColor: Colors.white,
    ).copyWith(
      onBackground: Colors.black,
      onSurface: Colors.black,
    );

    final TextTheme mainTextTheme = Theme.of(context).textTheme;

    final MaterialStateProperty<EdgeInsetsGeometry> buttonPadding =
        MaterialStateProperty.all<EdgeInsetsGeometry>(
      const EdgeInsets.symmetric(
        horizontal: themeConstants.padding_medium,
        vertical: themeConstants.padding_tiny,
      ),
    );

    final MaterialStateProperty<RoundedRectangleBorder> buttonShape =
        MaterialStateProperty.all<RoundedRectangleBorder>(
      const RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(themeConstants.radius),
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Voice Scribe',
        home: MainScreen(),
        theme: ThemeData.from(
          colorScheme: mainColorScheme,
          textTheme: mainTextTheme,
        ).copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: mainColorScheme.surface,
            foregroundColor: mainColorScheme.onSurface,
            backwardsCompatibility: false,
            elevation: themeConstants.elevation,
          ),
          bottomAppBarTheme: BottomAppBarTheme(
            color: mainColorScheme.surface,
            elevation: themeConstants.elevation,
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.vertical(
                top: const Radius.circular(themeConstants.radius),
              ),
            ),
          ),
          cardTheme: const CardTheme(
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(themeConstants.radius),
              ),
            ),
            elevation: themeConstants.elevation,
          ),
          dialogTheme: DialogTheme(
            elevation: themeConstants.high_elevation,
            contentTextStyle: mainTextTheme.subtitle1,
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(themeConstants.radius),
              ),
            ),
          ),
          dividerTheme: const DividerThemeData(
            thickness: themeConstants.divider_thickness,
            space: 0.0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all<double>(
                themeConstants.elevation,
              ),
              padding: buttonPadding,
              shape: buttonShape,
            ),
          ),
          iconTheme: IconThemeData(
            color: mainColorScheme.onSurface,
          ),
          popupMenuTheme: PopupMenuThemeData(
            elevation: themeConstants.high_elevation,
            textStyle: mainTextTheme.subtitle1,
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(themeConstants.radius),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              padding: buttonPadding,
              shape: buttonShape,
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
    );
  }
}
