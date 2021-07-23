import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mono_theme_constants.dart';

final ThemeData mainTheme = ThemeData(
  primarySwatch: Colors.red,
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: GoogleFonts.montserratTextTheme(),
  appBarTheme: AppBarTheme(
    color: Colors.white,
    elevation: ELEVATION,
    actionsIconTheme: IconThemeData(
      color: Colors.black,
      size: ICON_SIZE,
    ),
  ),
  iconTheme: IconThemeData(size: ICON_SIZE),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: MaterialStateProperty.all<double>(ELEVATION),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.all(BUTTON_PADDING),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RADIUS_LARGE),
        ),
      ),
    ),
  ),
  cardTheme: CardTheme(
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RADIUS),
    ),
    elevation: ELEVATION,
  ),
  popupMenuTheme: PopupMenuThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RADIUS),
    ),
  ),
  dividerColor: Colors.black26,
  dividerTheme: const DividerThemeData(thickness: DIVIDER_THICKNESS),
  bottomSheetTheme: const BottomSheetThemeData(
    shape: const RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(
        top: const Radius.circular(RADIUS),
      ),
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RADIUS)),
  ),
);
