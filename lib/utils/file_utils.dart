import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Provides utility functions and extensions for working with [File]s and
/// [Directory]s.
///
/// Meant to be used with the import alias "file_utils".

const Uuid _uuid = Uuid();

extension RelativeGenerator on Directory {
  /// Gets the path to the [FileSystemEntity] with the given [entityName] in
  /// this directory.
  String pathIn(String entityName) {
    return path.join(this.path, entityName);
  }

  /// Gets the [Directory] with [dirName] in this directory.
  Directory dir(String dirName) {
    return Directory(this.pathIn(dirName));
  }

  /// Gets the [File] with [fileName] and [extension] in this directory.
  ///
  /// [extension] is optional. If given, the dot separator may be omitted or
  /// included.
  File file(String fileName, [String extension = '']) {
    // Add dot separator to extension if not present.
    if (extension.isNotEmpty && !extension.startsWith('.')) {
      extension = '.' + extension;
    }
    return File(this.pathIn('$fileName$extension'));
  }
}

extension FileRelativeRename on File {
  /// Renames the file relative to its parent directory.
  ///
  /// The extension may be omitted. In that case, the current extension will
  /// be reused.
  Future<File> relativeRename(String newName, [String extension = '']) {
    if (extension.isEmpty) {
      extension = path.extension(newName);
    }
    String newPath = path.join(this.parent.path, '$newName$extension');
    return this.rename(newPath);
  }
}

extension DirectoryRelativeRename on Directory {
  /// Renames the directory relative to its parent directory.
  Future<Directory> relativeRename(String newName) {
    String newPath = path.join(this.parent.path, newName);
    return this.rename(newPath);
  }
}

/// Generates a unique ID.
///
/// Often times used to create unique names for temporary files.
String uniqueID() {
  return _uuid.v1();
}
