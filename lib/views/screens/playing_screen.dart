import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player.dart';
import '../../models/recording.dart';
import '../../models/transcript_reader.dart' as transcriptReader;
import "../../utils/formatter.dart" as formatter;
import '../../utils/theme_constants.dart';
import '../widgets/playback_slider.dart';
import '../widgets/mono_theme_widgets.dart';

class PlayingScreen extends StatelessWidget {
  final Recording recording;
  final Player _player;

  PlayingScreen({@required this.recording}) : _player = Player();

  Future<Player> _initializePlayer() async {
    await _player.initialize();
    await _player.startPlayer(recording);
    return _player;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_player.active) await _player.stopPlayer();
        if (_player.opened) await _player.close();
        return true;
      },
      child: FutureBuilder(
        future: _initializePlayer(),
        builder: (BuildContext context, AsyncSnapshot<Player> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ChangeNotifierProvider.value(
              value: snapshot.data,
              child: FreeScaffold(
                body: Column(
                  children: [
                    _Header(recording: recording),
                    const SizedBox(height: PADDING_LARGE),
                    Expanded(
                      child: recording.transcriptionExists
                          ? _TranscriptView(recording: recording)
                          : const Align(
                              alignment: Alignment.topLeft,
                              child: const _NoTranscriptIndicator(),
                            ),
                    ),
                    const SizedBox(height: PADDING_LARGE),
                    PlaybackSlider(),
                    const SizedBox(height: PADDING_MEDIUM),
                    _ButtonRow(),
                  ],
                ),
              ),
            );
          } else {
            return FreeScaffold(
              loading: true,
            );
          }
        },
      ),
    );
  }
}

/// Displays [recording] name and date.
class _Header extends StatelessWidget {
  final Recording recording;

  const _Header({@required this.recording});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          recording.name,
          style: Theme.of(context).textTheme.subtitle1,
          // style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(height: PADDING_SMALL),
        Text(
          formatter.formatDate(recording.date),
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
}

/// Displays the contents of the transcript of the given [recording].
class _TranscriptView extends StatelessWidget {
  final Recording recording;

  const _TranscriptView({@required this.recording});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: transcriptReader.read(recording.transcriptionFile),
      builder: (
        BuildContext context,
        AsyncSnapshot<Map<Duration, String>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<Duration, String> transcriptMap = snapshot.data;
          return Scrollbar(
            child: ListView.builder(
              itemCount: transcriptMap.length * 2 - 1,
              itemBuilder: (BuildContext context, int index) {
                if (index % 2 == 0) {
                  return _TranscriptResult(
                    startTime: transcriptMap.keys.elementAt(index ~/ 2),
                    resultText: transcriptMap.values.elementAt(index ~/ 2),
                  );
                } else {
                  return SizedBox(height: PADDING_MEDIUM);
                }
              },
            ),
          );
        } else {
          return const Center(child: const CircularProgressIndicator());
        }
      },
    );
  }
}

/// Displays a single result (chunk of speech) in a transcript.
class _TranscriptResult extends StatelessWidget {
  final Duration startTime;
  final String resultText;

  const _TranscriptResult({
    @required this.startTime,
    @required this.resultText,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            style: Theme.of(context).textTheme.caption,
            text: formatter.formatDuration(startTime) + '\n',
          ),
          TextSpan(
            style: Theme.of(context).textTheme.bodyText1,
            text: resultText,
          ),
        ],
      ),
    );
  }
}

/// Indicates the absence of a transcript.
class _NoTranscriptIndicator extends StatelessWidget {
  const _NoTranscriptIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.attach_file),
        const SizedBox(width: PADDING_MEDIUM),
        const Text('No transcript'),
      ],
    );
  }
}

class _ButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Player player = Provider.of<Player>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MonoIconButton(
          iconData: Icons.replay_5,
          onPressed: () => player.changePositionRelative(Duration(seconds: -5)),
        ),
        SizedBox(width: PADDING_MEDIUM),
        _MainButton(),
        SizedBox(width: PADDING_MEDIUM),
        MonoIconButton(
          iconData: Icons.forward_10,
          onPressed: () => player.changePositionRelative(Duration(seconds: 10)),
        ),
      ],
    );
  }
}

/// The main button in the player that changes based on the player state.
class _MainButton extends StatelessWidget {
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
