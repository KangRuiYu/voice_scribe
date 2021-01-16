import 'dart:io';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class Recording {
  // Holds information on a single recording
  final String path;
  final String name;
  final double length;
  final String date;
  final String version; // The version of the model

  Recording(File file)
      : path = file.path,
        name = basenameWithoutExtension(file.path),
        length = 10,
        date = DateFormat.yMMMd().format(file.lastModifiedSync()),
        version = '0.1';

  Recording.fromJson(Map<String, dynamic> json)
      : path = json['path'],
        name = json['name'],
        length = json['length'],
        date = json['date'],
        version = json['version'];

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'length': length,
        'date': date,
        'version': version,
      };
}
