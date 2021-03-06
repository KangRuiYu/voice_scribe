import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/models/recordings_manager.dart';

import 'package:voice_scribe/views/screens/import_screen.dart';

class ThemedBottomAppBar extends StatelessWidget {
  final Widget child;
  final bool notched;

  ThemedBottomAppBar({@required this.child, this.notched = true});

  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: notched ? CircularNotchedRectangle() : null,
      notchMargin: -10,
      elevation: 10,
      child: Container(
        height: 55,
        child: child,
      ),
    );
  }
}

class DefaultBottomButtons extends StatelessWidget {
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (BuildContext context) => BottomModalSheet(),
          ),
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => null,
        ),
      ],
    );
  }
}

class BottomModalSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          SizedBox(height: 16),
          _MenuButton(
            label: 'Sort by',
            iconData: Icons.sort,
            onPressed: () => null,
          ),
          _MenuButton(
            label: 'Scan for recordings',
            iconData: Icons.find_in_page,
            onPressed: () {
              Navigator.pop(
                  context); // Close modal sheet before switching screens
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ImportScreen(
                    recordingsManager:
                        Provider.of<RecordingsManager>(context, listen: false),
                  ),
                ),
              );
            },
          ),
          Divider(),
          _MenuButton(
            label: 'Settings',
            iconData: Icons.settings,
            onPressed: () => null,
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  // The handle at the top of a sheet
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black12,
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  // A button shown in a menu
  final String label;
  final IconData iconData;
  final Function onPressed;

  _MenuButton({
    @required this.label,
    @required this.iconData,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Theme.of(context).accentColor,
        textStyle: Theme.of(context).textTheme.button.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      child: SizedBox(width: double.infinity, child: Text(label)),
      onPressed: onPressed,
    );
  }
}
