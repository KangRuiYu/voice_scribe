import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/models/player.dart';
import 'package:voice_scribe/views/widgets/playback_slider.dart';
import 'package:voice_scribe/views/widgets/duration_display.dart';
import 'package:voice_scribe/views/widgets/custom_buttons.dart';
import 'package:voice_scribe/utils/formatter.dart' as formatter;
import 'package:voice_scribe/views/widgets/mono_theme_widgets.dart';

class PlayingScreen extends StatelessWidget {
  final Recording recording;

  PlayingScreen({@required this.recording});

  Future<Player> _initializePlayer() async {
    Player player = Player();
    await player.initialize();
    await Future.delayed(Duration(seconds: 1));
    player.startPlayer(recording);
    return player;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.red,
      ),
      child: FutureBuilder(
        future: _initializePlayer(),
        builder: (BuildContext context, AsyncSnapshot<Player> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ChangeNotifierProvider.value(
              value: snapshot.data,
              child: WillPopScope(
                child: AppbarScaffold(
                  title: 'Player',
                  body: Column(
                    children: [
                      _DetailsCard(),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 20),
                      _PresuppliedPlaybackSlider(),
                      _CurrentAndTotalDurationDisplay(),
                      const SizedBox(height: 20),
                      _ButtonRow(),
                    ],
                  ),
                ),
                onWillPop: () async {
                  snapshot.data.stopPlayer();
                  return true;
                },
              ),
            );
          } else {
            return AppbarScaffold(
              title: 'Player',
              loadingBar: true,
            );
          }
        },
      ),
    );
  }
}

class _PresuppliedPlaybackSlider extends StatelessWidget {
  // A playback slider with all its required values provided by default
  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
        builder: (BuildContext context, Player player, Widget child) {
      return PlaybackSlider(
        stream: player.onProgress,
        seekPlayerFunc: player.changePosition,
      );
    });
  }
}

class _CurrentAndTotalDurationDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
      builder: (BuildContext context, Player player, Widget child) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DurationDisplay(
              stream: player.onProgress,
              textStyle: Theme.of(context).textTheme.subtitle1,
              useDuration: false,
            ),
            Text('  |  ', style: Theme.of(context).textTheme.subtitle1),
            DurationDisplay(
              stream: player.onProgress,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        );
      },
    );
  }
}

class _ButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
        builder: (BuildContext context, Player player, Widget child) {
      Function backFunc;
      Function forwardFunc;

      if (player.active || player.finished) {
        backFunc = () => player.changePositionRelative(Duration(seconds: -5));
        forwardFunc =
            () => player.changePositionRelative(Duration(seconds: 10));
      } else {
        backFunc = () => null;
        forwardFunc = () => null;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.replay_5),
            onPressed: backFunc,
          ),
          _MainButton(),
          IconButton(
            icon: Icon(Icons.forward_10),
            onPressed: forwardFunc,
          ),
        ],
      );
    });
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
          iconData: Icons.pause,
          onPressed: player.pausePlayer,
        );
      } else {
        Function pressedFunc;

        if (player.paused) // Choose function based on the state of the player
          pressedFunc = player.resumePlayer;
        else if (player.finished)
          pressedFunc = player.restartPlayer;
        else
          pressedFunc = () => null;

        return CircularIconButton(
          iconData: Icons.play_arrow,
          onPressed: pressedFunc,
        );
      }
    });
  }
}

class _DetailsCard extends StatelessWidget {
  // Shows the details of the player's recording
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
                Provider.of<Player>(context, listen: false).recording.name,
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 10),
              Text(
                formatter.formatDate(
                    Provider.of<Player>(context, listen: false).recording.date),
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
