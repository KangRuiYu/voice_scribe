import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:voice_scribe/constants/app_constants.dart' as app_constants;
import 'package:voice_scribe/constants/theme_constants.dart' as theme_constants;
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/views/screens/import_screen.dart';
import 'package:voice_scribe/views/screens/recording_screen.dart';
import 'package:voice_scribe/views/widgets/custom_widgets.dart';
import 'package:voice_scribe/views/widgets/recordings_display.dart';

/// The starting screen of the application.
class MainScreen extends StatelessWidget {
  void _showRecordingScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) => RecordingScreen()),
    );
  }

  /// Used to initialize [RecordingsManager] using [context.watch] to avoid
  /// unnecessary rebuilds.
  Future<void> _initializeRecordingsManager(BuildContext context) async {
    await context.read<RecordingsManager>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          context.watch<Future<void> Function()>().call(), // Call to onReady.
      builder: (BuildContext _, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
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
                actions: [const _MenuButton()],
              ),
              floatingActionButton: CircularIconButton(
                iconData: Icons.fiber_manual_record_rounded,
                onPressed: () => _showRecordingScreen(context),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              body: FutureBuilder(
                future: _initializeRecordingsManager(context),
                builder: (BuildContext _, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      !snapshot.hasError) {
                    return RecordingsDisplay();
                  } else {
                    return CenterLoadingIndicator();
                  }
                },
              ),
            ),
          );
        } else {
          return LoadingScreen();
        }
      },
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
      MaterialPageRoute(builder: (BuildContext context) => ImportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void Function()>(
      icon: const Icon(Icons.more_vert_rounded),
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
          value: () => showLicensePage(
            context: context,
            applicationName: app_constants.name,
            applicationVersion: app_constants.version,
            applicationLegalese: app_constants.copyright,
            applicationIcon: Padding(
              padding: const EdgeInsets.all(theme_constants.padding_small),
              child: CircleAvatar(
                radius: theme_constants.big_icon_size,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset('assets/icon.png'),
                ),
              ),
            ),
          ),
          child: Text('About'),
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
