import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recording.dart';
import '../../models/recordings_manager.dart';
import '../../utils/formatter.dart';
import '../../utils/theme_constants.dart' as theme_constants;
import '../widgets/custom_widgets.dart';

/// Keeps track of selected recordings while notifying any listeners.
class Selector extends ChangeNotifier {
  /// Currently selected recordings.
  UnmodifiableSetView<Recording> get selected => UnmodifiableSetView(_selected);
  Set<Recording> _selected = {};

  /// Selects the given [recording].
  ///
  /// If the [recording] is already selected, nothing happens.
  /// Notifies any listeners.
  void select(Recording recording) {
    _selected.add(recording);
    notifyListeners();
  }

  /// Deselects the give [recording].
  ///
  /// If the [recording] is not selected, nothing happens.
  /// Notifies any listeners.
  void deselect(Recording recording) {
    _selected.remove(recording);
    notifyListeners();
  }

  /// Returns true if [recording] is currently selected.
  bool isSelected(Recording recording) {
    return _selected.contains(recording);
  }
}

class ImportScreen extends StatelessWidget {
  const ImportScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: context
            .select((RecordingsManager rm) => rm.unknownRecordingFiles)
            .call(),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Recording>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            return MultiProvider(
              providers: [
                Provider.value(value: snapshot.data),
                ChangeNotifierProvider(create: (_) => Selector()),
              ],
              child: Scaffold(
                appBar: AppBar(title: const _SelectedCountLabel()),
                floatingActionButton: const _ImportButton(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: const ThemedBottomAppBar(
                  rightChild: const _SelectOptionsButton(),
                ),
                body: const _RecordingList(),
              ),
            );
          } else {
            return const Scaffold(
              body: const Center(child: const CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

/// Label indicating the number of recordings currently selected.
class _SelectedCountLabel extends StatelessWidget {
  const _SelectedCountLabel();

  @override
  Widget build(BuildContext context) {
    return Consumer<Selector>(
      builder: (BuildContext context, Selector selector, Widget _) {
        if (selector.selected.length == 0) {
          return const Text('None selected');
        } else {
          return Text(selector.selected.length.toString() + ' selected');
        }
      },
    );
  }
}

/// Popup menu button that allows selection/deselection of all recordings.
class _SelectOptionsButton extends StatelessWidget {
  const _SelectOptionsButton();

  @override
  Widget build(BuildContext context) {
    return Consumer2<List<Recording>, Selector>(
      builder: (
        BuildContext context,
        List<Recording> recordings,
        Selector selector,
        Widget _,
      ) {
        return PopupMenuButton<void Function()>(
          icon: const Icon(Icons.more_vert),
          initialValue: () => null,
          onSelected: (void Function() func) => func(),
          tooltip: 'More options',
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: () => recordings.forEach(
                (Recording recording) => selector.select(recording),
              ),
              enabled: selector.selected.length < recordings.length,
              child: const Text('Select all'),
            ),
            PopupMenuItem(
              value: () => recordings.forEach(
                (Recording recording) => selector.deselect(recording),
              ),
              enabled: selector.selected.length != 0,
              child: const Text('Deselect all'),
            ),
          ],
        );
      },
    );
  }
}

/// Button that imports selected recordings in [Selector] into [RecordingsManager].
class _ImportButton extends StatelessWidget {
  const _ImportButton();

  @override
  Widget build(BuildContext context) {
    return CircularIconButton(
      iconData: Icons.file_download,
      onPressed: () async {
        Selector selector = context.read<Selector>();
        RecordingsManager recordingsManager = context.read<RecordingsManager>();

        for (Recording recording in selector.selected) {
          await recordingsManager.add(recording);
        }

        Navigator.pop(context);
      },
    );
  }
}

/// Displays a list of recordings along side their selected state in [Selector].
class _RecordingList extends StatelessWidget {
  const _RecordingList();

  @override
  Widget build(BuildContext context) {
    return Consumer<List<Recording>>(
      builder: (
        BuildContext context,
        List<Recording> recordings,
        Widget _,
      ) {
        return ListView.builder(
          itemCount: recordings.length > 0 ? recordings.length + 2 : 0,
          itemBuilder: (BuildContext context, int index) {
            if (index >= recordings.length) {
              return const SizedBox(height: theme_constants.padding_huge);
            } else {
              return _RecordingListing(recordings[index]);
            }
          },
        );
      },
    );
  }
}

/// A listing of a [Recording] in a [_RecordingList].
class _RecordingListing extends StatelessWidget {
  final Recording recording;

  const _RecordingListing(this.recording);

  @override
  Widget build(BuildContext context) {
    return Consumer<Selector>(
      builder: (BuildContext context, Selector selector, Widget _) {
        return Card(
          margin: const EdgeInsets.only(
            top: theme_constants.padding_tiny,
            right: theme_constants.padding_small,
            left: theme_constants.padding_small,
          ),
          child: CheckboxListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(theme_constants.radius),
            ),
            contentPadding: const EdgeInsets.only(
              left: theme_constants.padding_huge,
              right: theme_constants.padding_small,
            ),
            title: Text(recording.name),
            subtitle: Text(formatDate(recording.date)),
            value: selector.isSelected(recording),
            onChanged: (bool selected) {
              if (selected) {
                selector.select(recording);
              } else {
                selector.deselect(recording);
              }
            },
          ),
        );
      },
    );
  }
}
