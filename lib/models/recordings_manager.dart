import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';

import 'package:voice_scribe/models/recording.dart';

class RecordingsManager extends ChangeNotifier {
  // Manages all the saved recordings
  final List<Recording> _recordings = [];
  List<Recording> get recordings => _recordings;

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
