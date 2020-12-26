import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';

class RecordingsManager extends ChangeNotifier {
  // Manages all the saved recordings
  final List<RecordingInfo> _recordings = [];
  List<RecordingInfo> get recordings => _recordings;

  void loadRecordings() async {
    // Loads all recordings from the import files
    Directory importsDirectory = await _getImportsDirectory();

    _recordings.clear();

    importsDirectory.list().listen(
      (FileSystemEntity entity) {
        if (entity is File && extension(entity.path) == '.import') {
          String data = entity.readAsStringSync();
          RecordingInfo ri = RecordingInfo.fromJson(jsonDecode(data));
          _recordings.add(ri);
        }
      },
      onDone: () => notifyListeners(),
    );
  }

  void addRecording(RecordingInfo recording) {
    // Adds the recording to the recordings list and imports it
    _recordings.add(recording);
    _createImportFile(recording);
    notifyListeners();
  }

  Future<Directory> _getImportsDirectory() async {
    // Returns the imports directory and creates one if one doesn't already exist
    Directory externalStorageDirectory = await getExternalStorageDirectory();
    Directory importsDirectory =
        Directory(join(externalStorageDirectory.path, '.imports'));

    importsDirectory
        .createSync(); // Creates the imports directory if it doesn't already exist

    return importsDirectory;
  }

  void _createImportFile(RecordingInfo recording) async {
    // Creates an import file for the given recording
    Directory importsDirectory = await _getImportsDirectory();
    File importFile =
        File(join(importsDirectory.path, '${recording.name}.import'));
    importFile.writeAsStringSync(jsonEncode(recording.toJson()));
  }
}

class RecordingInfo {
  // Holds information on a single recording
  final String path;
  final String name;
  final double length;
  final String date;

  RecordingInfo(File file)
      : path = file.path,
        name = basenameWithoutExtension(file.path),
        length = 10,
        date = 'Saturday';

  RecordingInfo.fromJson(Map<String, dynamic> json)
      : path = json['path'],
        name = json['name'],
        length = json['length'],
        date = json['date'];

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'length': length,
        'date': date,
      };
}
