import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/views/screens/main_screen.dart';
import 'package:voice_scribe/models/recordings_manager.dart';

import 'package:voice_scribe/models/player.dart';

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
          accentColor: Colors.black87,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.openSansTextTheme(),
          appBarTheme: AppBarTheme(
            elevation: 0,
            color: Colors.transparent,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            textTheme: GoogleFonts.openSansTextTheme().copyWith(
              headline6: GoogleFonts.openSans(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
          dividerTheme: DividerThemeData(
            color: Colors.black26,
            thickness: 1,
          ),
          buttonTheme: ButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            textTheme: ButtonTextTheme.primary,
          ),
          sliderTheme: SliderThemeData(),
          bottomSheetTheme: BottomSheetThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
        ),
        home: MainScreen(),
      ),
    );
  }
}
