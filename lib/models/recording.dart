import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_dart;

const _current_version = '0.2';

/// Contains an audio file's metadata.
class Recording {
  /// The audio file itself.
  File get audioFile => _audioFile;
  File _audioFile;

  /// The transcription file itself.
  File get transcriptionFile => _transcriptionFile;
  File _transcriptionFile;

  /// The length of the recording. Could be inaccurate.
  Duration duration;

  /// The date in which the recording was created. May not match audio file's.
  DateTime date;

  /// The Recording model version this was originally created in.
  String version;

  /// Name of the audio file.
  String get name => path_dart.basenameWithoutExtension(audioPath);

  /// The path to the audio file itself.
  String get audioPath => _audioFile.path;
  set audioPath(String newPath) => _audioFile = File(newPath);

  /// Path to the transcription file. May not exist.
  String get transcriptionPath => _transcriptionFile.path;
  set transcriptionPath(String newPath) => _transcriptionFile = File(newPath);

  /// Returns true if the audio for this exists.
  bool get audioExists => _audioFile.existsSync();

  /// Returns true if the transcription for this exists.
  bool get transcriptionExists => _transcriptionFile.existsSync();

  /// Creates a new recording using given files and info.
  ///
  /// If no [transcriptionFile] is given, it defaults to a File pointing to an
  /// empty path, signifying the absence of a transcription file.
  /// The [date] of the recording is the this is constructed.
  /// The [version] of the recording is the version on construction.
  Recording({
    @required File audioFile,
    File transcriptionFile,
    @required Duration duration,
  })  : this._audioFile = audioFile,
        this._transcriptionFile = transcriptionFile ?? File(''),
        this.duration = duration,
        this.date = DateTime.now(),
        this.version = _current_version;

  /// Creates a new recording using given string paths and info.
  ///
  /// If no [transcriptionPath] is given, it defaults to an empty path,
  /// signifying the absence of a transcription file.
  /// The [date] of the recording is the time this is constructed.
  /// The [version] of the recording is the version on construction.
  Recording.path({
    @required String audioPath,
    String transcriptionPath = '',
    @required Duration duration,
  })  : this._audioFile = File(audioPath),
        this._transcriptionFile = File(transcriptionPath),
        this.duration = duration,
        this.date = DateTime.now(),
        this.version = _current_version;

  /// Creates a recording from a JSON map.
  Recording.fromJson(Map<String, dynamic> json)
      : _audioFile = File(json['audioPath']),
        _transcriptionFile = File(json['transcriptionPath']),
        duration = Duration(milliseconds: json['duration_in_milliseconds']),
        date = DateTime(json['year'], json['month'], json['day']),
        version = json['version'];

  /// Creates a JSON map containing the recording information.
  ///
  /// Some information accuracy, like exact duration, may be lost.
  Map<String, dynamic> toJson() => {
        'audioPath': audioPath,
        'transcriptionPath': transcriptionPath,
        'duration_in_milliseconds': duration.inMilliseconds,
        'day': date.day,
        'month': date.month,
        'year': date.year,
        'version': version,
      };

  /// Deletes the audio file associated with this recording.
  ///
  /// If audio file could not be deleted (file does not exist), then a
  /// [FileSystemException] is thrown.
  Future<FileSystemEntity> deleteAudio() => _audioFile.delete();

  /// Deletes the transcription file associated with this recording.
  ///
  /// If transcription file could not be deleted (file does not exist), then a
  /// [FileSystemException] is thrown.
  Future<FileSystemEntity> deleteTranscription() => _transcriptionFile.delete();

  @override
  String toString() {
    return 'RECORDING\n' +
        'Name: $name\n' +
        'Audio Path: $audioPath\n' +
        'Transcription Path: $transcriptionPath\n' +
        'Duration: $duration\n' +
        'Date: $date\n';
  }
}
