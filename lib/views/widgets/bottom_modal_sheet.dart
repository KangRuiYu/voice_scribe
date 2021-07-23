import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recordings_manager.dart';
import '../../utils/mono_theme_constants.dart';
import '../screens/import_screen.dart';

class BottomModalSheet extends StatelessWidget {
  // A bottom modal sheet that shows the apps common functions (settings, etc)

  void showSortChoiceDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => _SortChoiceDialog(),
    );
  }

  void showImportScreen(BuildContext context) {
    Navigator.pop(context); // Close modal sheet before switching screens
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ImportScreen(
          recordingsManager:
              Provider.of<RecordingsManager>(context, listen: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PADDING_LARGE),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: PADDING_MEDIUM),
          _MenuButton(
            label: 'Sort by',
            iconData: Icons.sort,
            onPressed: () => showSortChoiceDialog(context),
          ),
          _MenuButton(
            label: 'Scan for recordings',
            iconData: Icons.find_in_page,
            onPressed: () => showImportScreen(context),
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

class _SortChoiceDialog extends StatelessWidget {
  // A popup dialog showing available sorting choices

  void sortByName(BuildContext context) {
    Provider.of<RecordingsManager>(context, listen: false).sort(
      sortFunction: RecordingsManager.byName,
    );
    Navigator.pop(context);
  }

  void sortByDate(BuildContext context) {
    Provider.of<RecordingsManager>(context, listen: false).sort(
      sortFunction: RecordingsManager.byDate,
    );
    Navigator.pop(context);
  }

  void sortByDuration(BuildContext context) {
    Provider.of<RecordingsManager>(context, listen: false).sort(
      sortFunction: RecordingsManager.byDuration,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Sort by'),
      children: [
        SimpleDialogOption(
          child: const Text('Name'),
          onPressed: () => sortByName(context),
        ),
        SimpleDialogOption(
          child: const Text('Date'),
          onPressed: () => sortByDate(context),
        ),
        SimpleDialogOption(
          child: const Text('Duration'),
          onPressed: () => sortByDuration(context),
        ),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  // The handle at the top of a sheet
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.0,
      height: 6.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RADIUS_LARGE),
        color: Colors.black26,
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  // A text button that is displayed in a menu
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
        primary: Theme.of(context).textTheme.button.color,
        textStyle: Theme.of(context).textTheme.button.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      child: SizedBox(width: double.infinity, child: Text(label)),
      onPressed: onPressed,
    );
  }
}
