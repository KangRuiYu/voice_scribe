import 'dart:io';

import 'file_utils.dart' as file_utils;

/// Utility functions for retrieving paths to model files.
///
/// Meant to imported with the alias 'model_utils'.

const List<String> supportedModels = ['vosk-model-small-en-us-0.15'];

/// Returns the path of the first model that exists in the given [modelDirectory].
/// If none are available, an empty string is returned.
Future<String> firstModelIn(Directory modelDirectory) async {
  for (String modelName in supportedModels) {
    Directory model = modelDirectory.dir(modelName);

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
