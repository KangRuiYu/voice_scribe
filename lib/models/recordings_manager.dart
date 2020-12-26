import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';

class RecordingsManager extends ChangeNotifier {
  // Manages all the saved recordings
  final List<RecordingInfo> _recordings = [];
  List<RecordingInfo> get recordings => _recordings;

  void loadRecordings() async {
    // Loads all recordings from the import json
    File imports = await _getImportsFile();

    String data = imports.readAsStringSync();
    List<dynamic> jsonData = jsonDecode(data);

    _recordings.clear();

    for (var obj in jsonData) {
      _recordings.add(RecordingInfo.fromJson(obj));
    }

    notifyListeners();
  }

  void reimportRecordings() async {
    // Re-imports all recordings from the app's storage and also reloads them
    File imports = await _getImportsFile();

    _recordings.clear();

    List<Map<String, dynamic>> dataList = [];

    imports.parent.list().listen(
      (FileSystemEntity entity) {
        if (entity is File && extension(entity.path) == '.aac') {
          RecordingInfo ri = RecordingInfo(entity);
          _recordings.add(ri);
          dataList.add(ri.toJson());
        }
      },
      onDone: () => imports.writeAsStringSync(jsonEncode(dataList)),
    );
  }

  void updateImportsFile() async {
    // Updates the imports file with the current recordings list
    File imports = await _getImportsFile();

    List<Map<String, dynamic>> dataList = [];

    for (RecordingInfo ri in _recordings) {
      dataList.add(ri.toJson());
    }

    imports.writeAsStringSync(jsonEncode(dataList));
  }

  void addRecording(RecordingInfo recording) {
    // Adds the recording to the recordings list and updates the json file
    _recordings.add(recording);
    updateImportsFile();
    notifyListeners();
  }

  Future<File> _getImportsFile() async {
    Directory dir = await getExternalStorageDirectory();
    return File(join(dir.path, 'imports.json'));
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
