import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/utils/formatter.dart';

import 'package:voice_scribe/views/widgets/custom_buttons.dart';
import 'package:voice_scribe/views/widgets/themed_bottom_appbar.dart';

class _ImportState extends ChangeNotifier {
  final RecordingsManager _recordingsManager;
  Map<File, bool> _files = {}; // File; To Import
  Map<File, bool> get files => _files;

  _ImportState(this._recordingsManager) {
    _initialize();
  }

  void _initialize() async {
    await for (File file in _recordingsManager.scanForUnimportedFiles()) {
      _files[file] = false;
      notifyListeners();
    }
  }

  void check(File file, bool value) {
    // Checks the following file in the dictionary to the given value.
    // Will do nothing if the file doesn't exist.
    if (_files.containsKey(file)) {
      _files[file] = value;
    }
  }

  Future<void> importFiles() async {
    // Imports all currently checked files
    for (MapEntry entry in _files.entries) {
      File file = entry.key;
      bool checked = entry.value;
      if (checked) {
        await _recordingsManager.importRecordingFile(file);
      }
    }
  }
}

class ImportScreen extends StatelessWidget {
  final RecordingsManager recordingsManager;

  ImportScreen({@required this.recordingsManager});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider(
        create: (BuildContext context) => _ImportState(recordingsManager),
        child: Scaffold(
          appBar: AppBar(title: const Text('Import')),
          body: _FileList(),
          floatingActionButton: _ImportButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: ThemedBottomAppBar(
            child: Center(),
            notched: false,
          ),
        ),
      ),
    );
  }
}

class _ImportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      leading: Icon(Icons.download_outlined),
      child: const Text('Import'),
      onPressed: () async {
        await Provider.of<_ImportState>(context, listen: false).importFiles();
        Navigator.pop(context);
      },
    );
  }
}

class _FileList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, _ImportState importState, Widget child) {
        return ListView.builder(
          itemCount: importState.files.length > 0
              ? importState.files.length * 2 - 1
              : 0,
          itemBuilder: (BuildContext context, int index) {
            if (index % 2 == 0) {
              File file = importState.files.keys.elementAt(index ~/ 2);
              return _FileListing(
                file: file,
                checkCallback: importState.check,
                startingCheckedValue: importState.files[file],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Divider(),
              );
            }
          },
        );
      },
    );
  }
}

class _FileListing extends StatefulWidget {
  // A listing of a file in the imports screen
  final File file;
  final Function checkCallback;
  final bool startingCheckedValue;
  String get _name => basenameWithoutExtension(file.path);
  String get _date => formatDate(file.lastAccessedSync());

  _FileListing({
    @required this.file,
    @required this.checkCallback,
    @required this.startingCheckedValue,
  });

  @override
  _FileListingState createState() => _FileListingState();
}

class _FileListingState extends State<_FileListing> {
  bool _checked = false;

  @override
  void initState() {
    _checked = widget.startingCheckedValue;
    super.initState();
  }

  void onChecked(bool value) {
    setState(
      () {
        _checked = value;
        widget.checkCallback(widget.file, value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () => onChecked(!_checked),
        child: ListTile(
          title: Text(widget._name),
          subtitle: Text(widget._date),
          trailing: Checkbox(
            value: _checked,
            onChanged: onChecked,
          ),
        ),
      ),
    );
  }
}
