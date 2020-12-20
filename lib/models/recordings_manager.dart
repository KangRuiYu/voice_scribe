import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class RecordingsManager extends ChangeNotifier{
  // Manages all the saved recordings
  final List<RecordingInfo> _recordings = [];
  List<RecordingInfo> get recordings => _recordings;

  void refreshRecordings() async {
    // Updates the recordings list
    Directory dir = await getExternalStorageDirectory();

    dir.list().listen((FileSystemEntity entity) {
      if (entity is File) {
        recordings.add(RecordingInfo(entity));
      }
    });

    notifyListeners();
  }
}

class RecordingInfo {
  // Holds information on a single recording
  final File file;
  String name;
  final double length = 10;
  final String date = 'Saturday';

  RecordingInfo(this.file) {
    name = basenameWithoutExtension(file.path);
  }
}
