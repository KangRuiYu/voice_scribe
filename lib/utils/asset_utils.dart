/// Provides functions for retrieving specific application assets and
/// directories.
///
/// Meant to be used with an import alias of 'assets'.

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const _recording_dir_path = 'recordings';
const _metadata_dir_name = 'metadata';
const _model_dir_name = 'models';
const _transcription_dir_name = 'transcriptions';

/// Creates all the main directories if they do not already exist and returns
/// them as a map.
Future<Map<String, Directory>> createDirectories() async {
  List<Directory> directoryList = await Future.wait([
    (await recordingsDirectory()).create(),
    (await metadataDirectory()).create(),
    (await modelDirectory()).create(),
    (await transcriptionDirectory()).create(),
  ]);
  return {
    'recordingsDirectory': directoryList[0],
    'metadataDirectory': directoryList[1],
    'modelDirectory': directoryList[2],
    'transcriptionDirectory': directoryList[3],
  };
}

/// Returns the directory in which recordings are stored.
///
/// The directory returned may not exist.
Future<Directory> recordingsDirectory() async {
  return Directory(path.join(await _baseDirPath(), _recording_dir_path));
}

/// Returns the directory in which metadata files are stored.
///
/// The directory returned may not exist.
Future<Directory> metadataDirectory() async {
  return Directory(path.join(await _baseDirPath(), _metadata_dir_name));
}

/// Returns the directory in which models are stored.
///
/// The directory returned may not exist.
Future<Directory> modelDirectory() async {
  return Directory(path.join(await _baseDirPath(), _model_dir_name));
}

/// Returns the directory in which transcriptions are stored.
///
/// The directory returned may not exist.
Future<Directory> transcriptionDirectory() async {
  return Directory(path.join(await _baseDirPath(), _transcription_dir_name));
}

/// Returns the base directory path in which everything is stored.
Future<String> _baseDirPath() async {
  return (await getExternalStorageDirectory()).path;
}
