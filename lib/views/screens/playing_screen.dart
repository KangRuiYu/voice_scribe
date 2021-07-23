import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player.dart';
import '../../models/recording.dart';
import "../../utils/formatter.dart" as formatter;
import '../../utils/mono_theme_constants.dart';
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
                    _DetailsCard(),
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

class _MainButton extends StatelessWidget {
  // The main button in the player that changes based on the player state
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

class _DetailsCard extends StatelessWidget {
  // Shows the details of the player's recording
  @override
  Widget build(BuildContext context) {
    Recording recording = Provider.of<Player>(context, listen: false).recording;
    return Expanded(
      child: Container(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(PADDING_LARGE),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recording.name,
                    style: Theme.of(context).textTheme.headline5,
                    // style: Theme.of(context).textTheme.headline5,
                  ),
                  const SizedBox(height: PADDING_SMALL),
                  Text(
                    formatter.formatDate(recording.date),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(height: PADDING_SMALL),
                  Text(
                    formatter.formatDuration(recording.duration),
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  const SizedBox(height: PADDING_SMALL),
                  Text(
                    recording.audioPath,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
