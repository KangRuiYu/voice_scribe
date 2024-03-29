import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/constants/theme_constants.dart' as theme_constants;
import 'package:voice_scribe/models/audio/player.dart';
import 'package:voice_scribe/models/audio/recording.dart';
import 'package:voice_scribe/models/transcript/transcript_reader.dart'
    as transcriptReader;
import 'package:voice_scribe/views/widgets/playback_slider.dart';
import 'package:voice_scribe/views/widgets/custom_widgets.dart';
import 'package:voice_scribe/views/widgets/transcript_result.dart';

class PlayingScreen extends StatelessWidget {
  final Recording recording;
  final Player player;

  PlayingScreen({@required this.recording}) : player = Player();

  Future<Player> _initializePlayer() async {
    if (player.active) return player;
    await player.initialize();
    await player.startPlayer(recording);
    return player;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (player.active) await player.stopPlayer();
        if (player.opened) await player.close();
        return true;
      },
      child: SafeArea(
        child: FutureBuilder(
          future: _initializePlayer(),
          builder: (BuildContext context, AsyncSnapshot<Player> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: Text(recording.name)),
                body: ChangeNotifierProvider.value(
                  value: snapshot.data,
                  child: Column(
                    children: [
                      recording.transcriptFile.existsSync()
                          ? _TranscriptView(recording: recording)
                          : const _NoTranscriptIndicator(),
                      const _ControlPanel(),
                    ],
                  ),
                ),
              );
            } else {
              return const Scaffold(
                body: const Center(child: const CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}

/// Displays the contents of the transcript of the given [recording].
class _TranscriptView extends StatelessWidget {
  final Recording recording;

  const _TranscriptView({@required this.recording});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: transcriptReader.read(recording.transcriptFile),
        builder: (
          BuildContext context,
          AsyncSnapshot<Map<Duration, String>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<Duration, String> transcriptMap = snapshot.data;
            return Scrollbar(
              child: ListView.builder(
                itemCount: transcriptMap.length,
                itemBuilder: (BuildContext context, int index) {
                  return TranscriptResult(
                    timestamp: transcriptMap.keys.elementAt(index),
                    resultText: transcriptMap.values.elementAt(index),
                  );
                },
              ),
            );
          } else {
            return const Center(child: const CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

/// Indicates the absence of a transcript.
class _NoTranscriptIndicator extends StatelessWidget {
  const _NoTranscriptIndicator();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(theme_constants.padding_large),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              const Icon(Icons.attach_file),
              const SizedBox(width: theme_constants.padding_medium),
              const Text('No transcript'),
            ],
          ),
        ),
      ),
    );
  }
}

/// A panel containing playback slider and buttons for nearest [Player].
class _ControlPanel extends StatelessWidget {
  const _ControlPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(theme_constants.padding_large),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: kElevationToShadow[theme_constants.elevation],
      ),
      child: Column(
        children: [
          const PlaybackSlider(),
          const SizedBox(height: theme_constants.padding_medium),
          const _ButtonRow(),
        ],
      ),
    );
  }
}

/// Main row of buttons.
class _ButtonRow extends StatelessWidget {
  const _ButtonRow();

  @override
  Widget build(BuildContext context) {
    Function changePositionRelative = context.select(
      (Player player) => player.changePositionRelative,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_5),
          onPressed: () => changePositionRelative(Duration(seconds: -5)),
        ),
        const SizedBox(width: theme_constants.padding_medium),
        const _MainButton(),
        const SizedBox(width: theme_constants.padding_medium),
        IconButton(
          icon: const Icon(Icons.forward_10),
          onPressed: () => changePositionRelative(Duration(seconds: 10)),
        ),
      ],
    );
  }
}

/// The main button in the player that changes based on the player state.
class _MainButton extends StatelessWidget {
  const _MainButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
      builder: (BuildContext context, Player player, Widget child) {
        if (player.playing) {
          return CircularIconButton(
            iconData: Icons.pause_rounded,
            onPressed: player.pausePlayer,
          );
        } else if (player.paused) {
          return CircularIconButton(
            iconData: Icons.play_arrow_rounded,
            onPressed: player.resumePlayer,
          );
        } else {
          return CircularIconButton(
            iconData: Icons.play_arrow_rounded,
            onPressed: player.restartPlayer,
          );
        }
      },
    );
  }
}
