import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/views/screens/recording_screen.dart';
import 'package:voice_scribe/views/widgets/bottom_modal_sheet.dart';
import 'package:voice_scribe/views/widgets/mono_theme_widgets.dart';
import 'package:voice_scribe/views/widgets/recordings_display.dart';

class MainScreen extends StatelessWidget {
  void startRecording(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider.value(
            value: Provider.of<RecordingsManager>(context, listen: false),
            child: RecordingScreen(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppbarScaffold(
      title: 'Recordings',
      bottomAppbar: MonoBottomAppBar(child: BottomAppBarButtons()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CircularIconButton(
        iconData: Icons.fiber_manual_record_rounded,
        onPressed: () => startRecording(context),
      ),
      body:
          Provider.of<RecordingsManager>(context, listen: true).recordingsLoaded
              ? RecordingsDisplay()
              : Center(child: const CircularProgressIndicator()),
    );
  }
}

class BottomAppBarButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (BuildContext context) => BottomModalSheet(),
          ),
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => null,
        ),
      ],
    );
  }
}
