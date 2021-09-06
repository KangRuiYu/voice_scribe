import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

enum DownloadState { none, downloading, unzipping, finished }

/// Downloads and unzips transcription model located in Firebase and notifies
/// any listeners on the current progress.
class ModelDownloader extends ChangeNotifier {
  DownloadState get state => _state;
  DownloadState _state = DownloadState.none;

  /// Ranges from 0 to 1.
  double get progress => _progress;
  double _progress = 0.0;

  /// Used by the [cancel] method.
  DownloadTask _downloadTask;

  /// Downloads model with [modelName] and saving it into [savePath].
  ///
  /// Model will first be downloaded to the given [downloadPath] then unzipped
  /// into [unzipPath].
  /// Any left over files will be removed.
  /// If there is a task in progress (ie. downloading or unzipping), then a
  /// [DownloadInProgress] exception is thrown.
  Future<void> download({
    @required String modelName,
    @required String downloadPath,
    @required String unzipPath,
    @required String savePath,
  }) async {
    if (state == DownloadState.downloading ||
        state == DownloadState.unzipping) {
      throw DownloadInProgress();
    }

    // Create a Firebase instance if there is not one.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    await _fireStorageDownload(modelName, downloadPath);
    await _unzipFile(downloadPath, unzipPath);

    // Move file to save path.
    await Directory(savePath).create(recursive: true);
    await Directory(unzipPath).rename(savePath);
    await File(downloadPath).delete(recursive: true);

    _state = DownloadState.finished;
    _progress = 1.0;

    notifyListeners();
  }

  /// Cancels any ongoing download task.
  ///
  /// Updates the [state] to none and notifies listeners, regardless of whether
  /// or not there is an ongoing task.
  Future<void> cancel() async {
    await _downloadTask?.cancel();
    _state = DownloadState.none;
    notifyListeners();
  }

  /// Downloads file with [filePath] in Firebase Storage to [outputPath].
  ///
  /// Will notify listeners of progress for every snapshot.
  Future<void> _fireStorageDownload(String filePath, String outputPath) async {
    File outputFile = await File(outputPath).create(recursive: true);
    Reference model = FirebaseStorage.instance.ref(filePath);
    _downloadTask = model.writeToFile(outputFile);

    _state = DownloadState.downloading;

    StreamSubscription<TaskSnapshot> _snapshotSub =
        _downloadTask.snapshotEvents.listen(
      (TaskSnapshot snapshot) {
        _progress = snapshot.bytesTransferred / snapshot.totalBytes;
        notifyListeners();
      },
    );

    await _downloadTask;
    _downloadTask = null;
    _snapshotSub.cancel();
  }

  /// Unzips the file with [zipFilePath] into [outputPath].
  ///
  /// Notifies listeners of progress for each file that is unzipped.
  Future<void> _unzipFile(String zipFilePath, String outputPath) async {
    Archive archive = ZipDecoder().decodeBytes(
      await File(zipFilePath).readAsBytes(),
    );

    int filesProcessed = 0;
    _state = DownloadState.unzipping;

    for (ArchiveFile file in archive.files) {
      if (file.isFile) {
        final data = file.content as List<int>;

        File outputFile = File(path.join(outputPath, file.name));
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(data);
      } else {
        await Directory(
          path.join(outputPath, file.name),
        ).create(recursive: true);
      }

      _progress = (++filesProcessed) / archive.length;
      notifyListeners();
    }
  }
}

class DownloadInProgress implements Exception {
  final String message;
  const DownloadInProgress([this.message = '']);
}
