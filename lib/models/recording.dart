import 'dart:io';
import 'package:path/path.dart';

class Recording {
  // Holds information on a single recording
  final String path;
  final String name;
  final double length;
  final String date;

  Recording(File file)
      : path = file.path,
        name = basenameWithoutExtension(file.path),
        length = 10,
        date = 'Saturday';

  Recording.fromJson(Map<String, dynamic> json)
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
