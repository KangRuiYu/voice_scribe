import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'recording.dart';

/// Manages and provides access to the list of known recordings.
class RecordingsManager extends ChangeNotifier {
  /// The directory that stores all the recording files.
  final Directory recordingsDirectory;

  /// The directory that stores all the metadata files.
  final Directory metadataDirectory;

  /// The internal recordings list.
  UnmodifiableListView<Recording> get recordings =>
      UnmodifiableListView(_recordings);
  final List<Recording> _recordings = [];

  /// If this has finished loading all known recordings.
  bool get finishedLoading => _finishedLoading;
  bool _finishedLoading = false;

  // Sorting functions.
  static int byName(Recording a, Recording b) => a.name.compareTo(b.name);
  static int byDate(Recording a, Recording b) => a.date.compareTo(b.date);
  static int byDuration(Recording a, Recording b) =>
      a.duration.compareTo(b.duration);

  /// Currently applied sorting function.
  Comparator<Recording> get currentSortOrder => _currentSortOrder;
  Comparator<Recording> _currentSortOrder = byName;

  /// If the current sorting is reversed.
  bool get sortReversed => _sortReversed;
  bool _sortReversed = false;

  /// Default constructor.
  RecordingsManager({
    @required this.recordingsDirectory,
    @required this.metadataDirectory,
  });

  /// Load is called on construction.
  RecordingsManager.autoLoad({
    @required this.recordingsDirectory,
    @required this.metadataDirectory,
  }) {
    load();
  }

  /// Load known recordings.
  ///
  /// Clears any previously loaded recordings.
  Future<void> load() async {
    _recordings.clear();

    await for (FileSystemEntity entity in metadataDirectory.list()) {
      if (entity is File && path.extension(entity.path) == '.metadata') {
        Map<String, dynamic> metadata = jsonDecode(await entity.readAsString());
        Recording recording = Recording.fromJson(metadata);
        _recordings.add(recording);
      }
    }

    _finishedLoading = true;

    sort(); // NotifyListeners is called here.
  }

  /// Adds new [recording] to the list of known recordings.
  ///
  /// Creates a new metadata file for it.
  Future<void> add(Recording recording) async {
    _recordings.add(recording);
    await saveMetadata(recording);
    notifyListeners();
  }

  /// Removes [recording] from the list of known recordings.
  ///
  /// Removes the metadata file for it.
  /// Optionally removes source files for it as well (audio and transcription).
  Future<void> remove(Recording recording, {bool deleteSource}) async {
    _recordings.remove(recording);

    List<Future> futureList = [];

    // Remove metadata file
    File metadataFile = _metadataFile(recording.name);
    futureList.add(metadataFile.delete());

    // Remove source files
    if (deleteSource) {
      if (recording.audioExists) {
        futureList.add(recording.deleteAudio());
      }
      if (recording.transcriptionExists) {
        futureList.add(recording.deleteTranscription());
      }
    }

    await Future.wait(futureList);

    notifyListeners();
  }

  /// Sorts the internal recordings list.
  void sort({
    Comparator<Recording> sortFunction = byName,
    bool reversed = false,
  }) {
    // Update state
    _currentSortOrder = sortFunction;
    _sortReversed = reversed;

    // Apply
    if (reversed) {
      _recordings.sort((Recording a, Recording b) => -sortFunction(a, b));
    } else {
      _recordings.sort(sortFunction);
    }

    notifyListeners();
  }

  /// Reverses the currently applied sorting order.
  void reverseSort() {
    sort(sortFunction: _currentSortOrder, reversed: !_sortReversed);
  }

  /// Returns the recordings that are not currently loaded.
  ///
  /// Will not work properly if [load] is not called beforehand.
  Future<List<File>> unknownRecordingFiles() async {
    Set<String> recordingNames = {};
    for (Recording recording in _recordings) {
      recordingNames.add(recording.name);
    }

    List<File> result = [];
    await for (FileSystemEntity entity in recordingsDirectory.list()) {
      if (entity is File && path.extension(entity.path) == '.wav') {
        String recordingName = path.basenameWithoutExtension(entity.path);
        if (!recordingNames.contains(recordingName)) {
          result.add(entity);
        }
      }
    }

    return result;
  }

  /// Creates a metadata file for the given recording.
  ///
  /// If the file already exists, it is overwritten.
  Future<void> saveMetadata(Recording recording) async {
    File metadata = _metadataFile(recording.name);
    await metadata.writeAsString(jsonEncode(recording.toJson()));
  }

  /// Returns the File containing the path to the metadata file with the given
  /// name.
  ///
  /// The file may not exist.
  File _metadataFile(String name) {
    return File(path.join(metadataDirectory.path, '$name.metadata'));
  }
}
