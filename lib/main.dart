import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/app_life_cycle_observer.dart';

import 'models/app_resources.dart';
import 'utils/theme_constants.dart' as themeConstants;
import 'views/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppResources appResources = await onStartup();
  AppLifeCycleObserver(onDetached: () => onExit(appResources)).startObserving();
  runApp(VoiceScribe(appResources));
}

/// Called on startup.
///
/// Creates resources, gathers permissions, and sets up directories.
Future<AppResources> onStartup() async {
  await Permission.microphone.request();
  await Permission.storage.request();

  AppResources appResources = await AppResources.create();

  if (await appResources.appDirs.tempDirectory.exists()) {
    await appResources.appDirs.tempDirectory.delete(recursive: true);
  }

  await appResources.appDirs.createAll();

  return appResources;
}

/// Called on exit.
///
/// Closes any resources and deletes the temporary directory.
Future<void> onExit(AppResources appResources) async {
  await Future.wait([
    appResources.appDirs.tempDirectory.delete(recursive: true),
    appResources.terminate(),
  ]);
}

/// The main app.
class VoiceScribe extends StatelessWidget {
  final AppResources appResources;

  VoiceScribe(this.appResources);

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

    return MultiProvider(
      providers: [
        Provider.value(value: appResources.appDirs),
        ChangeNotifierProvider.value(value: appResources.recordingsManager),
        ChangeNotifierProvider.value(value: appResources.recordingTranscriber),
        Provider.value(value: appResources.streamTranscriber),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white,
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Voice Scribe',
          home: FutureBuilder(
            future: appResources.initialize(),
            builder: (BuildContext _, AsyncSnapshot<AppResources> snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                return MainScreen();
              } else {
                return const SafeArea(
                  child: const Scaffold(
                    body: const Center(
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                );
              }
            },
          ),
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
      ),
    );
  }
}
