import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'file_dir_generator.dart' as fileDirGenerator;

/// Handles retrieving paths to model files.

const List<String> supportedModels = ['vosk-model-small-en-us-0.15'];
const String _modelDirectoryName = 'models';

/// Returns the path of the first model that exists. If none are available,
/// null is returned instead.
Future<String> firstAvailableModel() async {
  for (String modelName in supportedModels) {
    String modelPath = await _getModelPath(modelName);
    if (Directory(modelPath).existsSync()) {
      return modelPath;
    }
  }
  return null;
}

/// Returns the path of the first model that exists in the given [modelDirectory].
/// If none are available, an empty string is returned.
Future<String> firstModelIn(Directory modelDirectory) async {
  for (String modelName in supportedModels) {
    Directory model = fileDirGenerator.directoryIn(
      parentDirectory: modelDirectory,
      name: modelName,
    );

    if (await model.exists()) {
      return model.path;
    }
  }

  return '';
}

/// Returns true if there is a model available in the given [modelDirectory].
///
/// Typically better to use [firstModelIn] directly, but this is useful if you
/// do not need the actual model path.
Future<bool> modelAvailableIn(Directory modelDirectory) async {
  return (await firstModelIn(modelDirectory)).isNotEmpty;
}

/// Private method that gets the path to the model with the given name.
Future<String> _getModelPath(String modelName) async {
  return path.join(
    (await getExternalStorageDirectory()).path,
    _modelDirectoryName,
    modelName,
  );
}
