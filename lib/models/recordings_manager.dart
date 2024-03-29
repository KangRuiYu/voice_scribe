import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'package:voice_scribe/constants/file_extensions.dart' as file_extensions;
import 'package:voice_scribe/models/audio/recording.dart';
import 'package:voice_scribe/models/mixins/future_initializer.dart';
import 'package:voice_scribe/utils/file_utils.dart' as file_utils;

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

        try {
          _recordings.add(await Recording.existing(recordingSourceDir));
        } on MissingMetadataFile {
          entity.delete();
        }
      }
    }

    sort(); // NotifyListeners is called here.
  }

  /// Inserts new [recording] to the list of known recordings in the current
  /// sorting order.
  ///
  /// Creates a new import file for it.
  Future<void> add(Recording recording) async {
    _recordings.add(recording);
    await _createImportFile(recording);
    sort(
      sortFunction: _currentSortOrder,
      reversed: _sortReversed,
    ); // NotifyListeners is called here.
  }

  /// Updates the state of the manager and import files based on any changes
  /// that may have occurred in [recording].
  ///
  /// Typically used after the [recording] has been moved or renamed.
  /// If the recording is not in the current records, nothing happens.
  Future<void> update(Recording recording) async {
    if (_recordings.contains(recording) == false) {
      return;
    }

    await _createImportFile(recording);
    sort(sortFunction: _currentSortOrder, reversed: _sortReversed);
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
    Set<String> knownSourceDirectoryPaths = {};
    for (Recording recording in _recordings) {
      knownSourceDirectoryPaths.add(recording.sourceDirectory.path);
    }

    List<Recording> result = [];
    await for (FileSystemEntity entity in recordingsDirectory.list()) {
      if (entity is Directory &&
          !knownSourceDirectoryPaths.contains(entity.path)) {
        File metadataFile = entity.file(
          path.basename(entity.path),
          file_extensions.metadata,
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
    return importsDirectory.file(recording.id, file_extensions.import);
  }
}
