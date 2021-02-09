import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/models/player.dart';
import 'package:voice_scribe/views/widgets/playback_slider.dart';
import 'package:voice_scribe/views/widgets/duration_display.dart';
import 'package:voice_scribe/views/widgets/custom_buttons.dart';
import 'package:voice_scribe/utils/formatter.dart' as formatter;

class PlayingScreen extends StatelessWidget {
  final Player _player = Player();

  PlayingScreen(Recording recording) {
    _player.startPlayer(recording, () => print('DONE'));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _player,
      child: WillPopScope(
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(title: Text('Player')),
            body: Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 32.0,
                left: 32.0,
                right: 32.0,
              ),
              child: Column(
                children: [
                  _DynamicView(),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 20),
                  _DynamicPlaybackSlider(),
                  _DynamicDurationDisplay(),
                  const SizedBox(height: 20),
                  _DynamicButtons(),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          _player.stopPlayer();
          return true;
        },
      ),
    );
  }
}

class _DynamicView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
        builder: (BuildContext context, Player player, Widget child) {
      if (player.playing || player.paused)
        return _DetailsCard(player);
      else
        return Center();
    });
  }
}

class _DynamicPlaybackSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
        builder: (BuildContext context, Player player, Widget child) {
      if (player.playing || player.paused)
        return PlaybackSlider(
          player.progress,
          (double value) {
            player.changePosition(Duration(milliseconds: value.toInt()));
          },
        );
      else
        return Center();
    });
  }
}

class _DynamicDurationDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
      builder: (BuildContext context, Player player, Widget child) {
        if (player.playing || player.paused)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DurationDisplay(
                stream: player.progress,
                textStyle: Theme.of(context).textTheme.subtitle1,
                useDuration: false,
              ),
              Text('  |  ', style: Theme.of(context).textTheme.subtitle1),
              DurationDisplay(
                stream: player.progress,
                textStyle: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          );
        else
          return Center();
      },
    );
  }
}

class _DynamicButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
        builder: (BuildContext context, Player player, Widget child) {
      if (player.playing || player.paused)
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.replay_5),
              onPressed: () =>
                  player.changePositionRelative(Duration(seconds: -5)),
            ),
            player.playing
                ? _ActiveButtons(player.pausePlayer)
                : _PausedButtons(
                    player.resumePlayer,
                    () {
                      player.stopPlayer();
                      Navigator.of(context).pop();
                    },
                  ),
            IconButton(
              icon: Icon(Icons.forward_10),
              onPressed: () =>
                  player.changePositionRelative(Duration(seconds: 10)),
            ),
          ],
        );
      else
        return Center();
    });
  }
}

class _ActiveButtons extends StatelessWidget {
  final Function _onPause;

  _ActiveButtons(this._onPause);

  @override
  Widget build(BuildContext context) {
    return CircularIconButton(
      iconData: Icons.pause,
      onPressed: _onPause,
    );
  }
}

class _PausedButtons extends StatelessWidget {
  final Function _onResume;
  final Function _onStop;

  _PausedButtons(this._onResume, this._onStop);

  @override
  Widget build(BuildContext context) {
    return CircularIconButton(
      iconData: Icons.play_arrow,
      onPressed: _onResume,
    );
  }
}

class _DetailsCard extends StatelessWidget {
  // Shows the details of the player's recording
  final Player _player;

  _DetailsCard(this._player);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.music_note),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _player.recording.name,
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 10),
              Text(
                formatter.formatDate(_player.recording.date),
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
