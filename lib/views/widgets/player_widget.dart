import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/player.dart';
import 'package:voice_scribe/views/widgets/playback_duration.dart';
import 'package:voice_scribe/views/widgets/custom_buttons.dart';

class PlayerWidget extends StatelessWidget {
  // The buttons and sliders of the player
  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
      builder: (BuildContext context, Player player, Widget child) {
        if (player.playing || player.paused)
          return Column(
            children: [
              _DetailsCard(player),
              const SizedBox(height: 20),
              PlaybackSlider(
                player.progress,
                (double value) {
                  player.changePosition(Duration(milliseconds: value.toInt()));
                },
              ),
              const SizedBox(height: 20),
              player.playing
                  ? _PlayingButtons(player.pausePlayer)
                  : _PausedButtons(
                      player.resumePlayer,
                      () {
                        player.stopPlayer();
                        Navigator.of(context).pop();
                      },
                    ),
            ],
          );
        else
          return Center();
      },
    );
  }
}

class _PlayingButtons extends StatelessWidget {
  final Function _onPause;

  _PlayingButtons(this._onPause);

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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.music_note),
                ),
              ),
              Text(
                _player.recording.name,
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 10),
              Text(
                _player.recording.date,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
