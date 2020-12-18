import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:voice_scribe/models/recorder.dart';
import 'package:voice_scribe/views/recorder_widget.dart';
import 'package:voice_scribe/views/custom_buttons.dart';

class RecorderSlidingUpPanel extends StatelessWidget {
  final PanelController _panelController = new PanelController();

  Widget build(BuildContext context) {
    print(true);
    return ChangeNotifierProvider(
      create: (context) => Recorder(),
      child: SlidingUpPanel(
        controller: _panelController,
        minHeight: 80,
        borderRadius: const BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
        ),
        body: const Center(),
        collapsed: Consumer<Recorder>(
          builder: (context, recorder, child) {
            if (recorder.recording || recorder.paused) {
              return Center(
                child: MiniRecorderDisplay(recorder),
              );
            } else {
              return Center(
                child: CircularIconButton(
                  iconData: Icons.fiber_manual_record_rounded,
                  onPressed: () {
                    recorder.startRecording();
                    _panelController.open();
                  },
                ),
              );
            }
          },
        ),
        panel: Consumer<Recorder>(
          builder: (context, recorder, child) {
            return Center(
              child: RecorderDisplay(recorder),
            );
          },
        ),
      ),
    );
  }
}
