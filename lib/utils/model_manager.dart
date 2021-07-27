import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Handles retrieving paths to model files.

const List<String> _supportedModels = ['vosk-model-small-en-us-0.15'];
const String _modelDirectoryName = 'models';

/// Returns the path of the first model that exists. If none are available,
/// null is returned instead.
Future<String> firstAvailableModel() async {
  for (String modelName in _supportedModels) {
    String modelPath = await _getModelPath(modelName);
    if (Directory(modelPath).existsSync()) {
      return modelPath;
    }
  }
  return null;
}

/// Private method that gets the path to the model with the given name.
Future<String> _getModelPath(String modelName) async {
  return path.join(
    (await getExternalStorageDirectory()).path,
    _modelDirectoryName,
    modelName,
  );
}