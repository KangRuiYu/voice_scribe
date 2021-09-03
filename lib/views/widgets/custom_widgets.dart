import 'package:flutter/material.dart';

import '../../utils/theme_constants.dart' as themeConstants;

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
      height: themeConstants.bottom_app_bar_height,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarColor,
        boxShadow: kElevationToShadow[themeConstants.elevation],
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

/// A filled icon button.
class CircularIconButton extends StatelessWidget {
  final IconData iconData;
  final Function onPressed;

  const CircularIconButton({
    @required this.iconData,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle mainStyle = Theme.of(context).elevatedButtonTheme.style;
    final ButtonStyle customStyle = mainStyle.copyWith(
      shape: MaterialStateProperty.all<CircleBorder>(const CircleBorder()),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.all(themeConstants.padding_small),
      ),
    );

    return ElevatedButton(
      style: customStyle,
      child: Icon(
        iconData,
        size: themeConstants.big_icon_size,
      ),
      onPressed: onPressed,
    );
  }
}

/// Slightly bigger icon button.
class BigIconButton extends StatelessWidget {
  final IconData iconData;
  final Function onPressed;

  const BigIconButton({
    @required this.iconData,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconData),
      iconSize: themeConstants.big_icon_size,
      onPressed: onPressed,
    );
  }
}

/// Empty screen with a [CircularProgressIndicator] in the middle;
class LoadingScreen extends StatelessWidget {
  const LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: const Scaffold(
        body: const CenterLoadingIndicator(),
      ),
    );
  }
}

/// A widget that expands to parent constraints and displays a
/// [CircularProgressIndicator] in the middle.
class CenterLoadingIndicator extends StatelessWidget {
  const CenterLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(child: const CircularProgressIndicator());
  }
}
