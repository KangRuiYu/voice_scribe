import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const _import_dir_name = '.imports';
const _model_dir_name = 'models';
const _transcription_dir_name = 'transcriptions';

/// Returns the directory in which import files are stored.
///
/// The directory returned may not exist.
Future<Directory> importDirectory() async {
  return Directory(path.join(await _baseDirPath(), _import_dir_name));
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

/// Returns a File containing the path to the transcription with the given name.
///
/// The file may not exist.
Future<File> generateTranscriptionFile(String name) async {
  String transcriptionDirPath = (await transcriptionDirectory()).path;
  return File(path.join(transcriptionDirPath, '$name.transcription'));
}

/// Creates all the main directories if they do not already exist.
Future<void> createDirectories() async {
  await Future.wait([
    (await importDirectory()).create(),
    (await modelDirectory()).create(),
    (await transcriptionDirectory()).create(),
  ]);
}

/// Returns the base directory path in which everything is stored.
Future<String> _baseDirPath() async {
  return (await getExternalStorageDirectory()).path;
}
