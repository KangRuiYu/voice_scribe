import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:voice_scribe/utils/mono_theme_constants.dart';
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
        debugShowCheckedModeBanner: false,
        title: 'Voice Scribe',
        theme: ThemeData(
          primarySwatch: Colors.red,
          primaryColor: Colors.white,
          brightness: Brightness.light,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.montserratTextTheme(),
          appBarTheme: AppBarTheme(
            elevation: ELEVATION,
          ),
          iconTheme: IconThemeData(size: ICON_SIZE),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all<double>(ELEVATION),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(BUTTON_PADDING),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BUTTON_RADIUS),
                ),
              ),
            ),
          ),
          cardTheme: CardTheme(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CARD_RADIUS),
            ),
            elevation: ELEVATION,
          ),
          bottomAppBarTheme: BottomAppBarTheme(
            elevation: 16.0,
          ),
        ),
        home: MainScreen(),
      ),
    );
  }
}
