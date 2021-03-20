import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voice_scribe/utils/mono_theme_constants.dart';

class FreeScaffold extends StatelessWidget {
  // A scaffold without any appbars
  final Widget body;
  final bool loading;

  FreeScaffold({
    @required this.body,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: theme.scaffoldBackgroundColor,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(SCAFFOLD_BODY_PADDING),
            child: loading
                ? Center(
                    child: const CircularProgressIndicator(),
                  )
                : body,
          ),
        ),
      ),
    );
  }
}

class AppbarScaffold extends StatelessWidget {
  // A scaffold with an top appbar
  final String title;
  final Widget body;
  final bool loading;

  AppbarScaffold({
    @required this.title,
    @required this.body,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.scaffoldBackgroundColor,
            statusBarIconBrightness: theme.brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
          ),
          title: Text(title),
          bottom: loading
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

class CircularIconButton extends StatelessWidget {
  // A filled icon button
  final IconData iconData;
  final Function onPressed;

  CircularIconButton({
    @required this.iconData,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style.copyWith(
            shape: MaterialStateProperty.all<CircleBorder>(
              const CircleBorder(),
            ),
          ),
      child: Icon(iconData),
      onPressed: onPressed,
    );
  }
}

class MonoIconButton extends StatelessWidget {
  // A properly themed icon button
  final IconData iconData;
  final Function onPressed;

  MonoIconButton({
    @required this.iconData,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconData),
      iconSize: Theme.of(context).iconTheme.size,
      splashRadius: SPLASH_RADIUS,
      onPressed: onPressed,
    );
  }
}
