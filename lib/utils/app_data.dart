import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const _recordings_dir_name = 'recordings';
const _metadata_dir_name = 'metadata';
const _models_dir_name = 'models';
const _transcriptions_dir_name = 'transcriptions';

/// Provides easy access to application data directories.
///
/// Ensures that directories exist when retrieved.
class AppData {
  Directory get recordingsDirectory {
    _recordingsDirectory.createSync();
    return _recordingsDirectory;
  }

  Directory get metadataDirectory {
    _metadataDirectory.createSync();
    return _metadataDirectory;
  }

  Directory get modelsDirectory {
    _modelsDirectory.createSync();
    return _modelsDirectory;
  }

  Directory get transcriptionsDirectory {
    _transcriptionsDirectory.createSync();
    return _transcriptionsDirectory;
  }

  final Directory _recordingsDirectory;
  final Directory _metadataDirectory;
  final Directory _modelsDirectory;
  final Directory _transcriptionsDirectory;

  const AppData({
    @required Directory recordingsDirectory,
    @required Directory metadataDirectory,
    @required Directory modelsDirectory,
    @required Directory transcriptionsDirectory,
  })  : _recordingsDirectory = recordingsDirectory,
        _metadataDirectory = metadataDirectory,
        _modelsDirectory = modelsDirectory,
        _transcriptionsDirectory = transcriptionsDirectory;
}

/// Returns the directory in which recordings are stored.
///
/// The directory returned may not exist.
Future<Directory> recordingsDirectory() async {
  return _dataDirectory(_recordings_dir_name);
}

/// Returns the directory in which metadata files are stored.
///
/// The directory returned may not exist.
Future<Directory> metadataDirectory() async {
  return _dataDirectory(_metadata_dir_name);
}

/// Returns the directory in which models are stored.
///
/// The directory returned may not exist.
Future<Directory> modelsDirectory() async {
  return _dataDirectory(_models_dir_name);
}

/// Returns the directory in which transcriptions are stored.
///
/// The directory returned may not exist.
Future<Directory> transcriptionDirectory() async {
  return _dataDirectory(_transcriptions_dir_name);
}

/// Returns the data directory with the given name.
///
/// The directory returned may not exist.
Future<Directory> _dataDirectory(String directoryName) async {
  return Directory(
    path.join(
      (await _applicationDirectory()).path,
      directoryName,
    ),
  );
}

/// Return the application directory.
///
/// The directory returned may not exist.
Future<Directory> _applicationDirectory() {
  return getExternalStorageDirectory();
}
