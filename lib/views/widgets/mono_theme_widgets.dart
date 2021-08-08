import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/theme_constants.dart';

class FreeScaffold extends StatelessWidget {
  // A scaffold without any appbars
  final Widget body;
  final bool loading;
  final Widget bottomAppbar;
  final Widget floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;

  FreeScaffold({
    @required this.body,
    this.loading = false,
    this.bottomAppbar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
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
            padding: const EdgeInsets.all(PADDING_LARGE),
            child: loading
                ? Center(
                    child: const CircularProgressIndicator(),
                  )
                : body,
          ),
          bottomNavigationBar: bottomAppbar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
        ),
      ),
    );
  }
}

class AppbarScaffold extends StatelessWidget {
  // A scaffold with a top appbar
  final String title;
  final Widget body;
  final bool loading;
  final Widget bottomAppbar;
  final List<Widget> actions;
  final Widget floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;

  AppbarScaffold({
    @required this.title,
    @required this.body,
    this.loading = false,
    this.bottomAppbar,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: theme.appBarTheme.color,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
            actions: actions,
            bottom: loading
                ? PreferredSize(
                    child: const LinearProgressIndicator(),
                    preferredSize:
                        const Size(double.infinity, LOADING_BAR_HEIGHT),
                  )
                : null,
          ),
          body: body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          bottomNavigationBar: bottomAppbar,
        ),
      ),
    );
  }
}

/// A themed bottom app bar.
class ThemedBottomAppBar extends StatelessWidget {
  final Widget leftChild;
  final Widget rightChild;

  const ThemedBottomAppBar({
    this.leftChild = const SizedBox.shrink(),
    this.rightChild = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: bottom_app_bar_height,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarColor,
        boxShadow: kElevationToShadow[elevation],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [leftChild, const Spacer(), rightChild],
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
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.all(padding_small),
            ),
          ),
      child: Icon(
        iconData,
        size: circular_button_icon_size,
      ),
      onPressed: onPressed,
    );
  }
}

class MonoIconButton extends StatelessWidget {
  // Slightly bigger icon buttons
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
