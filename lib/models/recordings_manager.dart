import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voice_scribe/models/recording.dart';

class RecordingsManager extends ChangeNotifier {
  // Manages all the saved recordings
  final List<Recording> _recordings = [];
  List<Recording> get recordings => _recordings;

  // States
  bool _recordingsLoaded = false;
  bool get recordingsLoaded => _recordingsLoaded;

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

  RecordingsManager() {
    loadRecordings();
  }

  /// Load known recordings.
  Future<void> loadRecordings() async {
    Directory importsDirectory = await _getImportsDirectory();

    _recordings.clear();

    await for (FileSystemEntity entity in importsDirectory.list()) {
      if (entity is File && extension(entity.path) == '.import') {
        String data = entity.readAsStringSync();
        Recording ri = Recording.fromJson(jsonDecode(data));
        _recordings.add(ri);
      }
    }

    _recordingsLoaded = true;

    sortRecordings();
  }

  /// Adds a new recording to the recordings list and create a import file for
  /// it.
  void addNewRecording(Recording recording) {
    _recordings.add(recording);
    _createImportFile(recording);
    notifyListeners();
  }

  /// Removes the given recording and its import file. Optionally delete the
  /// actual file itself as well.
  Future<void> removeRecording(
    Recording recording, {
    bool deleteSource = false,
  }) async {
    // Remove recording
    _recordings.remove(recording);

    // Remove import file
    Directory importsDirectory = await _getImportsDirectory();
    File importFile =
        File(join(importsDirectory.path, '${recording.name}.import'));
    importFile.delete();

    // Remove source file
    if (deleteSource) {
      File recordingFile = File(recording.audioPath);
      recordingFile.delete();
    }

    notifyListeners();
  }

  /// Creates a recording object and import file for the given file.
  Future<void> importRecordingFile(File recordingFile) async {
    Duration duration = await flutterSoundHelper.duration(recordingFile.path);
    Recording recording = Recording(
      audioFile: recordingFile,
      duration: duration,
    );
    addNewRecording(recording);
  }

  /// Scans the primary directory for non-imported recording files.
  Stream<File> scanForUnimportedFiles() async* {
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
    if (sortFunction == _currentSortOrder && reversed == _sortReversed)
      return; // Return if the current recording list is already in the specified order.

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

  /// Reverses the currently applied sorting order.
  void reverseSort() {
    sortRecordings(sortFunction: _currentSortOrder, reversed: !_sortReversed);
  }

  /// Returns the imports directory and creates one if one doesn't already exist.
  Future<Directory> _getImportsDirectory() async {
    Directory externalStorageDirectory = await getExternalStorageDirectory();
    Directory importsDirectory =
        Directory(join(externalStorageDirectory.path, '.imports'));

    importsDirectory
        .create(); // Creates the imports directory if it doesn't already exist

    return importsDirectory;
  }

  /// Creates an import file for the given recording.
  void _createImportFile(Recording recording) async {
    Directory importsDirectory = await _getImportsDirectory();
    File importFile =
        File(join(importsDirectory.path, '${recording.name}.import'));
    importFile.writeAsString(jsonEncode(recording.toJson()));
  }
}
