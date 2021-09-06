import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'future_initializer.dart';
import '../utils/file_utils.dart' as file_utils;
import '../utils/file_extensions.dart' as file_extensions;
import 'recording.dart';

/// Manages and provides access to a list of known recordings.
class RecordingsManager extends ChangeNotifier
    with FutureInitializer<RecordingsManager> {
  /// The directory that stores all the recording source folders.
  final Directory recordingsDirectory;

  /// The directory that stores all the import files.
  final Directory importsDirectory;

  /// The internal recordings list.
  UnmodifiableListView<Recording> get recordings =>
      UnmodifiableListView(_recordings);
  final List<Recording> _recordings = [];

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
    @required this.importsDirectory,
  });

  @override
  @protected
  Future<RecordingsManager> onInitialize([Map<String, dynamic> args]) async {
    await load();
    return this;
  }

  /// Load known recordings.
  ///
  /// Clears any previously loaded recordings.
  Future<void> load() async {
    _recordings.clear();

    await for (FileSystemEntity entity in importsDirectory.list()) {
      if (entity is File &&
          path.extension(entity.path) == file_extensions.import) {
        Directory recordingSourceDir = Directory(
          await entity.readAsString(encoding: utf8),
        );

        _recordings.add(await Recording.existing(recordingSourceDir));
      }
    }

    sort(); // NotifyListeners is called here.
  }

  /// Adds new [recording] to the list of known recordings.
  ///
  /// Creates a new import file for it.
  Future<void> add(Recording recording) async {
    _recordings.add(recording);
    await _createImportFile(recording);
    notifyListeners();
  }

  /// Removes [recording] from the list of known recordings.
  ///
  /// Removes the import file for it.
  /// Optionally removes source files for it as well (audio and transcription).
  Future<void> remove(Recording recording, {bool deleteSource}) async {
    _recordings.remove(recording);

    List<Future> deletionFuture = [];

    // Remove import file.
    deletionFuture.add(_importFile(recording).delete());

    // Remove source files.
    if (deleteSource && await recording.sourceDirectory.exists()) {
      await recording.sourceDirectory.delete(recursive: true);
    }

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
  Future<List<Recording>> unknownRecordingFiles() async {
    Set<Directory> knownSourceDirectories = {};
    for (Recording recording in _recordings) {
      knownSourceDirectories.add(recording.sourceDirectory);
    }

    List<Recording> result = [];
    await for (FileSystemEntity entity in recordingsDirectory.list()) {
      if (entity is Directory && !knownSourceDirectories.contains(entity)) {
        File metadataFile = file_utils.fileIn(
          parentDirectory: entity,
          name: path.basename(entity.path),
          extension: file_extensions.metadata,
        );

        if (await metadataFile.exists()) {
          // Is a recording source directory.
          result.add(await Recording.existing(entity));
        }
      }
    }

    return result;
  }

  /// Creates a import file for the given [recording].
  ///
  /// If the import file already exists, it is overwritten.
  Future<void> _createImportFile(Recording recording) async {
    await _importFile(recording).writeAsString(recording.sourceDirectory.path);
  }

  /// Returns the import file associated with the given [recording].
  File _importFile(Recording recording) {
    return file_utils.fileIn(
      parentDirectory: importsDirectory,
      name: recording.id,
      extension: file_extensions.import,
    );
  }
}
