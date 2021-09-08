import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

import 'package:voice_scribe/utils/file_utils.dart' as file_utils;

/// Provides tools for managing and retrieve common application directories.

// Default application directory names.
const String default_recording_dir_name = 'recordings';
const String default_model_dir_name = 'models';
const String default_import_dir_name = '.imports';
const String default_temp_dir_name = '.temp';

/// Container for all data directories in the application.
class AppDirs {
  final Directory recordingsDirectory;
  final Directory modelsDirectory;
  final Directory importsDirectory;
  final Directory tempDirectory;

  const AppDirs({
    @required this.recordingsDirectory,
    @required this.modelsDirectory,
    @required this.importsDirectory,
    @required this.tempDirectory,
  });

  /// Creates all application directories if the do not exist.
  Future<void> createAll() async {
    await Future.wait([
      recordingsDirectory.create(recursive: true),
      modelsDirectory.create(recursive: true),
      importsDirectory.create(recursive: true),
      tempDirectory.create(recursive: true),
    ]);
  }
}

/// Where recording source folders are stored by default.
///
/// The directory returned may not exist.
Future<Directory> defaultRecordingsDir() async {
  return (await pathProvider.getExternalStorageDirectory()).dir(
    default_recording_dir_name,
  );
}

/// Where models are stored by default.
///
/// The directory returned may not exist.
Future<Directory> defaultModelDir() async {
  return (await pathProvider.getExternalStorageDirectory()).dir(
    default_model_dir_name,
  );
}

/// Where import files are stored by default.
///
/// The directory returned may not exist.
Future<Directory> defaultImportsDir() async {
  return (await pathProvider.getExternalStorageDirectory()).dir(
    default_import_dir_name,
  );
}

/// Where temp files are stored by default.
///
/// The directory returned may not exist.
Future<Directory> defaultTempDir() async {
  return (await pathProvider.getExternalStorageDirectory()).dir(
    default_temp_dir_name,
  );
}
