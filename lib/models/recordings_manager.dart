import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';

import 'package:voice_scribe/models/recording.dart';

class RecordingsManager extends ChangeNotifier {
  // Manages all the saved recordings
  final List<Recording> _recordings = [];
  List<Recording> get recordings => _recordings;

  // Sorting functions
  static Function byName =
      (Recording a, Recording b) => a.name.compareTo(b.name);
  static Function byDate =
      (Recording a, Recording b) => a.date.compareTo(b.date);
  static Function byDuration =
      (Recording a, Recording b) => a.duration.compareTo(b.duration);

  Function _currentSortOrder = byName; // Currently applied sorting
  bool _sortReversed = false; // If the sort is currently reversed
  bool get sortReversed => _sortReversed;

  void loadRecordings() async {
    // Create/load recordings from stored import files
    Directory importsDirectory = await _getImportsDirectory();

    _recordings.clear();

    await for (FileSystemEntity entity in importsDirectory.list()) {
      if (entity is File && extension(entity.path) == '.import') {
        String data = entity.readAsStringSync();
        Recording ri = Recording.fromJson(jsonDecode(data));
        _recordings.add(ri);
      }
    }

    sortRecordings();

    notifyListeners();
  }

  void addNewRecording(Recording recording) {
    // Adds a new recording to the recordings list and create a import file for it
    _recordings.add(recording);
    _createImportFile(recording);
    notifyListeners();
  }

  void removeRecording(Recording recording, {bool deleteSource = false}) async {
    // Removes the given recording and its import file. Optionally delete the
    // actual file itself as well.

    // Remove recording
    _recordings.remove(recording);

    // Remove import file
    Directory importsDirectory = await _getImportsDirectory();
    File importFile =
        File(join(importsDirectory.path, '${recording.name}.import'));
    importFile.delete();

    // Remove source file
    if (deleteSource) {
      File recordingFile = File(recording.path);
      recordingFile.delete();
    }

    notifyListeners();
  }

  Future<void> importRecordingFile(File recordingFile) async {
    // Creates a recording object and import file for the given file
    Duration duration = await flutterSoundHelper.duration(recordingFile.path);
    Recording recording = Recording(duration: duration, file: recordingFile);
    addNewRecording(recording);
  }

  Stream<File> scanForUnimportedFiles() async* {
    // Scans the primary directory for non-imported recording files
    Directory externalStorageDirectory = await getExternalStorageDirectory();

    await for (FileSystemEntity entity in externalStorageDirectory.list()) {
      if (entity is File) {
        String name = basenameWithoutExtension(entity.path);
        bool unique = true;

        for (Recording recording in _recordings) {
          // Search for any matching recording names
          if (name == recording.name) {
            unique = false;
            break;
          }
        }

        if (unique) yield entity;
      }
    }
  }

  void sortRecordings({Function sortFunction, bool reversed = false}) {
    // Setup
    if (sortFunction == null)
      sortFunction = byName; // Initialize to default if no function was given

    // Update state
    _currentSortOrder = sortFunction;
    _sortReversed = reversed;

    // Apply
    if (reversed)
      _recordings.sort((Recording a, Recording b) => -sortFunction(a, b));
    else
      _recordings.sort(sortFunction);

    notifyListeners();
  }

  void reverseSort() {
    // Reverses the currently applied sorting order
    sortRecordings(sortFunction: _currentSortOrder, reversed: !_sortReversed);
  }

  Future<Directory> _getImportsDirectory() async {
    // Returns the imports directory and creates one if one doesn't already exist
    Directory externalStorageDirectory = await getExternalStorageDirectory();
    Directory importsDirectory =
        Directory(join(externalStorageDirectory.path, '.imports'));

    importsDirectory
        .create(); // Creates the imports directory if it doesn't already exist

    return importsDirectory;
  }

  void _createImportFile(Recording recording) async {
    // Creates an import file for the given recording
    Directory importsDirectory = await _getImportsDirectory();
    File importFile =
        File(join(importsDirectory.path, '${recording.name}.import'));
    importFile.writeAsString(jsonEncode(recording.toJson()));
  }
}
