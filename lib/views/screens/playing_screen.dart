import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/models/player.dart';
import 'package:voice_scribe/views/widgets/playback_slider.dart';
import 'package:voice_scribe/utils/formatter.dart' as formatter;
import 'package:voice_scribe/views/widgets/mono_theme_widgets.dart';
import 'package:voice_scribe/utils/mono_theme_constants.dart';

class PlayingScreen extends StatelessWidget {
  final Recording recording;

  PlayingScreen({@required this.recording});

  Future<Player> _initializePlayer() async {
    Player player = Player();
    await player.initialize();
    player.startPlayer(recording);
    return player;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.red,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.all(BUTTON_PADDING),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BUTTON_RADIUS),
              ),
            ),
          ),
        ),
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
                      PlaybackSlider(),
                      const SizedBox(height: 20),
                      _ButtonRow(),
                    ],
                  ),
                ),
                onWillPop: () async {
                  await snapshot.data.stopPlayer();
                  await snapshot.data.close();
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
        } else if (player.paused) {
          return CircularIconButton(
            iconData: Icons.play_arrow,
            onPressed: player.resumePlayer,
          );
        } else {
          return CircularIconButton(
            iconData: Icons.play_arrow,
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
