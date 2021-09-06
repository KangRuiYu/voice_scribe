import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/constants/theme_constants.dart' as theme_constants;
import 'package:voice_scribe/models/app_life_cycle_observer.dart';
import 'package:voice_scribe/models/voice_scribe_state.dart';
import 'package:voice_scribe/views/screens/main_screen.dart';
import 'package:voice_scribe/views/screens/setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VoiceScribeState appState = VoiceScribeState();
  await appState.onBoot();
  AppLifeCycleObserver(
    onDetached: appState.onExit,
    onResumed: () => appState.requirementsManager.updateAllAndNotify(),
  ).startObserving();
  runApp(VoiceScribe(appState));
}

/// The main app.
class VoiceScribe extends StatelessWidget {
  final VoiceScribeState appState;
  final bool showMainScreenFirst;

  VoiceScribe(this.appState)
      : showMainScreenFirst = appState.requirementsManager.allSatisfied();

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
        horizontal: theme_constants.padding_medium,
        vertical: theme_constants.padding_tiny,
      ),
    );

    final MaterialStateProperty<RoundedRectangleBorder> buttonShape =
        MaterialStateProperty.all<RoundedRectangleBorder>(
      const RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(theme_constants.radius),
        ),
      ),
    );

    return MultiProvider(
      providers: [
        Provider.value(value: appState.onReady),
        Provider.value(value: appState.appDirs),
        ChangeNotifierProvider.value(value: appState.recordingsManager),
        ChangeNotifierProvider.value(value: appState.requirementsManager),
        ChangeNotifierProvider.value(value: appState.recordingTranscriber),
        Provider.value(value: appState.streamTranscriber),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white,
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Voice Scribe',
          home: showMainScreenFirst ? MainScreen() : SetupScreen(),
          theme: ThemeData.from(
            colorScheme: mainColorScheme,
            textTheme: mainTextTheme,
          ).copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: mainColorScheme.surface,
              foregroundColor: mainColorScheme.onSurface,
              backwardsCompatibility: false,
              elevation: theme_constants.elevation,
            ),
            bottomAppBarTheme: BottomAppBarTheme(
              color: mainColorScheme.surface,
              elevation: theme_constants.elevation,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              shape: const RoundedRectangleBorder(
                borderRadius: const BorderRadius.vertical(
                  top: const Radius.circular(theme_constants.radius),
                ),
              ),
            ),
            cardTheme: const CardTheme(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(theme_constants.radius),
                ),
              ),
              elevation: theme_constants.elevation,
            ),
            dialogTheme: DialogTheme(
              elevation: theme_constants.high_elevation,
              contentTextStyle: mainTextTheme.subtitle1,
              shape: const RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(theme_constants.radius),
                ),
              ),
            ),
            dividerTheme: const DividerThemeData(
              space: theme_constants.zero,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(
                  theme_constants.elevation,
                ),
                padding: buttonPadding,
                shape: buttonShape,
              ),
            ),
            iconTheme: IconThemeData(
              color: mainColorScheme.onSurface,
            ),
            popupMenuTheme: PopupMenuThemeData(
              elevation: theme_constants.high_elevation,
              textStyle: mainTextTheme.subtitle1,
              shape: const RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(theme_constants.radius),
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
      ),
    );
  }
}
