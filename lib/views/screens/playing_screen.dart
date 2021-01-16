import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recording.dart';
import 'package:voice_scribe/models/player.dart';
import 'package:voice_scribe/views/widgets/player_widget.dart';

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
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PlayerWidget(),
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
