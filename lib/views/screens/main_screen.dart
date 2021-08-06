import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'import_screen.dart';
import '../../models/recordings_manager.dart';
import 'recording_screen.dart';
import '../../utils/theme_constants.dart' as themeConstants;
import '../widgets/mono_theme_widgets.dart';
import '../widgets/recordings_display.dart';

/// The starting screen of the application.
class MainScreen extends StatelessWidget {
  void showRecordingScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ChangeNotifierProvider.value(
            value: Provider.of<RecordingsManager>(context, listen: false),
            child: RecordingScreen(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              const _SortOrderLabel(),
              const _ReverseSortButton(),
            ],
          ),
        ),
        floatingActionButton: CircularIconButton(
          iconData: Icons.fiber_manual_record_rounded,
          onPressed: () => showRecordingScreen(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _BottomAppBar(),
        body: Provider.of<RecordingsManager>(context, listen: true)
                .finishedLoading
            ? RecordingsDisplay()
            : Center(child: const CircularProgressIndicator()),
      ),
    );
  }
}

/// A label that displays the [RecordingsManager]'s current sorting order.
class _SortOrderLabel extends StatelessWidget {
  const _SortOrderLabel();

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingsManager>(
      builder: (
        BuildContext context,
        RecordingsManager recordingsManager,
        Widget _,
      ) {
        String title;
        if (recordingsManager.currentSortOrder == RecordingsManager.byName) {
          title = 'Sorted By Name';
        } else if (recordingsManager.currentSortOrder ==
            RecordingsManager.byDate) {
          title = 'Sorted By Date';
        } else {
          title = 'Sorted By Duration';
        }

        return Text(title);
      },
    );
  }
}

/// Displays [RecordingsManager]'s sorting direction and pressing it reverses it.
class _ReverseSortButton extends StatelessWidget {
  const _ReverseSortButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingsManager>(
      builder: (
        BuildContext context,
        RecordingsManager recordingsManager,
        Widget _,
      ) {
        return IconButton(
          icon: recordingsManager.sortReversed
              ? const Icon(Icons.arrow_drop_up)
              : const Icon(Icons.arrow_drop_down),
          onPressed: () => recordingsManager.reverseSort(),
        );
      },
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarColor,
        boxShadow: kElevationToShadow[themeConstants.elevation],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [
            const _MenuButton(),
            const Spacer(),
            IconButton(icon: const Icon(Icons.search), onPressed: () => null),
          ],
        ),
      ),
    );
  }
}

/// Button showing additional application options.
class _MenuButton extends StatelessWidget {
  const _MenuButton();

  void showSortChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _SortChoiceDialog(),
    );
  }

  void showImportScreen(BuildContext context) {
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
    return PopupMenuButton<void Function()>(
      icon: const Icon(Icons.menu),
      onSelected: (void Function() selectedFunction) => selectedFunction(),
      tooltip: 'Show more application options',
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: () => showSortChoiceDialog(context),
          child: Text('Sort by'),
        ),
        PopupMenuItem(
          value: () => showImportScreen(context),
          child: Text('Import Files'),
        ),
        PopupMenuItem(
          value: () => null,
          child: Text('Settings'),
        ),
      ],
    );
  }
}

/// Popup dialog with different sorting options for the [RecordingsManager].
class _SortChoiceDialog extends StatelessWidget {
  const _SortChoiceDialog();

  @override
  Widget build(BuildContext context) {
    final RecordingsManager recordingsManager =
        Provider.of<RecordingsManager>(context, listen: false);

    final TextStyle optionTextStyle = Theme.of(context).textTheme.bodyText2;

    return SimpleDialog(
      title: const Text('Sort by'),
      children: [
        SimpleDialogOption(
          child: Text('Name', style: optionTextStyle),
          onPressed: () {
            recordingsManager.sort(sortFunction: RecordingsManager.byName);
            Navigator.pop(context);
          },
        ),
        SimpleDialogOption(
          child: Text('Date', style: optionTextStyle),
          onPressed: () {
            recordingsManager.sort(sortFunction: RecordingsManager.byDate);
            Navigator.pop(context);
          },
        ),
        SimpleDialogOption(
          child: Text('Duration', style: optionTextStyle),
          onPressed: () {
            recordingsManager.sort(
              sortFunction: RecordingsManager.byDuration,
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
