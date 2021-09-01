import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Utility functions for getting files and directories within parent
/// directories.
///
/// Meant to be used with the import alias "fileDirGenerator".

/// Utility function constructing directory in given [parentDirectory].
Directory directoryIn({
  @required Directory parentDirectory,
  @required String name,
}) {
  return Directory(path.join(parentDirectory.path, name));
}

/// Utility function constructing file with given [extension] and [parentDirectory].
///
/// Can optionally include or omit dot separator in [extension].
File fileIn({
  @required Directory parentDirectory,
  @required String name,
  String extension = '',
}) {
  if (!extension.startsWith('.')) {
    // Add dot separator to extension if not present.
    extension = '.' + extension;
  }
  return File(path.join(parentDirectory.path, '$name$extension'));
}
