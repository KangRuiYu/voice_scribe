import 'package:flutter/material.dart';
import 'package:voice_scribe/utils/mono_theme_constants.dart';

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
                  child: const LinearProgressIndicator(),
                  preferredSize:
                      const Size(double.infinity, LOADING_BAR_HEIGHT),
                )
              : null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(SCAFFOLD_BODY_PADDING),
          child: body,
        ),
      ),
    );
  }
}
