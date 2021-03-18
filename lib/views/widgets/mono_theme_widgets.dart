import 'package:flutter/material.dart';
import 'package:voice_scribe/utils/mono_theme_constants.dart' as Constants;

class AppbarScaffold extends StatelessWidget {
  // A scaffold with an top appbar
  final String title;
  final Widget body;
  final bool loadingBar;

  AppbarScaffold({
    @required this.title,
    @required this.body,
    this.loadingBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: loadingBar
              ? PreferredSize(
                  child: LinearProgressIndicator(),
                  preferredSize: Size(double.infinity, 6.0),
                )
              : null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(Constants.SCAFFOLD_PADDING),
          child: body,
        ),
      ),
    );
  }
}
