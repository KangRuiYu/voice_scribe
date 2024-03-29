import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:voice_scribe/constants/file_extensions.dart' as file_extensions;
import 'package:voice_scribe/utils/file_utils.dart' as file_utils;

const _current_version = '0.3';

/// Recording object representing a "Recording Source Folder" on disk.
///
/// A Recording consists of a folder that contains three files.
/// (1) A .wav file, which contains the actual audio data.
/// (2) A .transcript file, which contains the transcript information for the
///     audio file.
/// (3) A .meta file, which contains the metadata for the audio file such as its
///     duration, date created, and version.
class Recording {
  /// The directory where all the source files are.
  Directory sourceDirectory;

  /// The length of the recording. Could be inaccurate.
  Duration duration;

  /// The date in which the recording was created. May not match audio file's.
  DateTime date;

  /// The Recording model version this was originally created in.
  String version;

  /// A unique 128-bit id used to identify this recording.
  String id;

  /// Name of the recording (Corresponds to the name of the asset directory).
  String get name => path.basenameWithoutExtension(sourceDirectory.path);

  File get audioFile => sourceDirectory.file(
        name,
        file_extensions.audio,
      );

  File get transcriptFile => sourceDirectory.file(
        name,
        file_extensions.transcript,
      );

  /// Location where the metadata (duration, date) of this recording is actually
  /// stored.
  File get metadataFile => sourceDirectory.file(
        name,
        file_extensions.metadata,
      );

  /// Creates a new recording using given info instead of reading from a metadata
  /// file.
  ///
  /// If no duration is given, defaults to [Duration.zero].
  /// If no date is given, defaults to the result of calling [DateTime.now].
  /// If no version is given, (generally should be left to defaults), then it
  /// will default to the current constant.
  /// If no id is given, (generally should be left to defaults), then it will
  /// default to a newly generated uuid.
  /// Creating a recording does not mean any of the assets actually exists.
  Recording({
    @required this.sourceDirectory,
    this.duration = Duration.zero,
    this.version = _current_version,
    this.date,
    this.id,
  }) {
    this.date ??= DateTime.now();
    this.id ??= file_utils.uniqueID();
  }

  /// Factory function that creates a recording pointing at the given
  /// [sourceDirectory].
  ///
  /// Infers metadata information from the metadata file in [sourceDirectory].
  /// If no metadata file exists, then a [MissingMetadataFile] exception is
  /// thrown.
  static Future<Recording> existing(Directory sourceDirectory) async {
    File metadataFile = sourceDirectory.file(
      path.basename(sourceDirectory.path),
      file_extensions.metadata,
    );

    if (!(await metadataFile.exists())) throw MissingMetadataFile();
    Map<String, dynamic> metadata = jsonDecode(
      await metadataFile.readAsString(),
    );

    return Recording(
      sourceDirectory: sourceDirectory,
      duration: Duration(milliseconds: metadata['duration_in_milliseconds']),
      date: DateTime(metadata['year'], metadata['month'], metadata['day']),
      version: metadata['version'],
      id: metadata['id'],
    );
  }

  /// Renames all inner files and the source directory itself to [newName].
  Future<void> rename(String newName) async {
    List<bool> fileExistsResults = await Future.wait([
      audioFile.exists(),
      transcriptFile.exists(),
      metadataFile.exists(),
    ]);

    List<Future> fileRenameTasks = [];

    if (fileExistsResults[0]) {
      fileRenameTasks.add(audioFile.relativeRename(newName));
    }
    if (fileExistsResults[1]) {
      fileRenameTasks.add(transcriptFile.relativeRename(newName));
    }
    if (fileExistsResults[2]) {
      fileRenameTasks.add(metadataFile.relativeRename(newName));
    }

    await Future.wait(fileRenameTasks);
    sourceDirectory = await sourceDirectory.relativeRename(newName);
  }

  /// Writes/Overwrites a metadata file containing the current metadata
  /// information into the [sourceDirectory].
  Future<void> writeMetadata() async {
    Map<String, dynamic> metadataContents = {
      'duration_in_milliseconds': duration.inMilliseconds,
      'day': date.day,
      'month': date.month,
      'year': date.year,
      'version': version,
      'id': id,
    };

    await metadataFile.writeAsString(jsonEncode(metadataContents));
  }

  @override
  String toString() {
    return 'RECORDING\n' +
        'Source Directory: ${sourceDirectory.path}\n' +
        'Audio Path: ${audioFile.path}\n' +
        'Transcript Path: ${transcriptFile.path}\n' +
        'Name: $name\n' +
        'Duration: $duration\n' +
        'Date: $date\n' +
        'Version: $version\n' +
        'ID: $id\n';
  }
}

class MissingMetadataFile implements Exception {
  final String message;
  const MissingMetadataFile([this.message]);
}
