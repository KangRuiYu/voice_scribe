import 'dart:io';
import 'package:path/path.dart';

class Recording {
  // Holds information on a single recording
  final String path;
  final String name;
  final Duration duration;
  final DateTime date;
  final String version; // The version of the model

  Recording({
    File file,
    this.duration,
  })  : path = file.path,
        name = basenameWithoutExtension(file.path),
        date = file.lastModifiedSync(),
        version = '0.1';

  Recording.inferFromFile(File file) // Infers duration of recording from file
      : path = file.path,
        name = basenameWithoutExtension(file.path),
        duration = Duration(seconds: 0),
        date = file.lastModifiedSync(),
        version = '0.1';

  Recording.fromJson(Map<String, dynamic> json)
      : path = json['path'],
        name = json['name'],
        duration = Duration(milliseconds: json['duration_in_milliseconds']),
        date = DateTime(json['year'], json['month'], json['day']),
        version = json['version'];

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'duration_in_milliseconds': duration.inMilliseconds,
        'day': date.day,
        'month': date.month,
        'year': date.year,
        'version': version,
      };
}
