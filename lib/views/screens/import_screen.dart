import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../../models/recording.dart';
import '../../models/recordings_manager.dart';
import '../../utils/formatter.dart';
import '../../utils/theme_constants.dart' as themeConstants;
import '../widgets/mono_theme_widgets.dart';

/// Keeps track of selected files while notifying any listeners.
class Selector extends ChangeNotifier {
  /// Currently selected files.
  UnmodifiableSetView<File> get selected => UnmodifiableSetView(_selected);
  Set<File> _selected = {};

  /// Selects the given [file].
  ///
  /// If the [file] is already selected, nothing happens.
  /// Notifies any listeners.
  void select(File file) {
    _selected.add(file);
    notifyListeners();
  }

  /// Deselects the give [file].
  ///
  /// If the [file] is not selected, nothing happens.
  /// Notifies any listeners.
  void deselect(File file) {
    _selected.remove(file);
    notifyListeners();
  }

  /// Returns true if [file] is currently selected.
  bool isSelected(File file) {
    return _selected.contains(file);
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
        builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
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
                body: const _FileList(),
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

/// Label indicating the number of files currently selected.
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

/// Popup menu button that allows selection/deselection of all files.
class _SelectOptionsButton extends StatelessWidget {
  const _SelectOptionsButton();

  @override
  Widget build(BuildContext context) {
    return Consumer2<List<File>, Selector>(
      builder: (
        BuildContext context,
        List<File> files,
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
              value: () => files.forEach((File file) => selector.select(file)),
              enabled: selector.selected.length < files.length,
              child: const Text('Select all'),
            ),
            PopupMenuItem(
              value: () => files.forEach(
                (File file) => selector.deselect(file),
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

/// Button that imports selected files in [Selector] into [RecordingsManager].
class _ImportButton extends StatelessWidget {
  const _ImportButton();

  @override
  Widget build(BuildContext context) {
    return CircularIconButton(
      iconData: Icons.file_download,
      onPressed: () async {
        Selector selector = context.read<Selector>();
        RecordingsManager recordingsManager = context.read<RecordingsManager>();

        for (File file in selector.selected) {
          await recordingsManager.add(
            Recording(
              audioFile: file,
              duration: await FlutterSoundHelper().duration(file.path),
            ),
          );
        }

        Navigator.pop(context);
      },
    );
  }
}

/// Displays a list of files along side their selected state in [Selector].
class _FileList extends StatelessWidget {
  const _FileList();

  @override
  Widget build(BuildContext context) {
    return Consumer<List<File>>(
      builder: (
        BuildContext context,
        List<File> files,
        Widget _,
      ) {
        return ListView.builder(
          itemCount: files.length > 0 ? files.length + 2 : 0,
          itemBuilder: (BuildContext context, int index) {
            if (index >= files.length) {
              return const SizedBox(height: themeConstants.padding_huge);
            } else {
              File file = files[index];
              return _FileListing(file);
            }
          },
        );
      },
    );
  }
}

/// A listing of a [file] in a [_FileList].
class _FileListing extends StatelessWidget {
  final File file;
  String get _name => basenameWithoutExtension(file.path);
  String get _date => formatDate(file.lastAccessedSync());

  const _FileListing(this.file);

  @override
  Widget build(BuildContext context) {
    return Consumer<Selector>(
      builder: (BuildContext context, Selector selector, Widget _) {
        return Card(
          margin: const EdgeInsets.only(
            top: themeConstants.padding_tiny,
            right: themeConstants.padding_medium,
            left: themeConstants.padding_medium,
          ),
          child: CheckboxListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(themeConstants.radius),
            ),
            contentPadding: const EdgeInsets.only(
              left: themeConstants.padding_medium,
              right: themeConstants.padding_small,
            ),
            title: Text(_name),
            subtitle: Text(_date),
            value: selector.isSelected(file),
            onChanged: (bool selected) {
              if (selected) {
                selector.select(file);
              } else {
                selector.deselect(file);
              }
            },
          ),
        );
      },
    );
  }
}
