import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'future_initializer.dart';
import 'recording_transcriber.dart';
import 'recordings_manager.dart';
import 'stream_transcriber.dart';
import '../utils/app_dir.dart';

/// Provides tools for managing and retrieve common application resources.

/// A container for the top level application resources.
///
/// Does not mean the resources are ready for use. They must be initialized
/// first.
class AppResources with FutureInitializer<AppResources> {
  final AppDirs appDirs;
  final RecordingsManager recordingsManager;
  final RecordingTranscriber recordingTranscriber;
  final StreamTranscriber streamTranscriber;

  // Prevent use of default constructor.
  AppResources._({
    @required this.appDirs,
    @required this.recordingsManager,
    @required this.recordingTranscriber,
    @required this.streamTranscriber,
  });

  static Future<AppResources> create() async {
    AppDirs appDirs = AppDirs(
      recordingsDirectory: defaultRecordingsDir(),
      modelsDirectory: await defaultModelDir(),
      importsDirectory: await defaultImportsDir(),
      tempDirectory: await defaultTempDir(),
    );

    RecordingsManager recordingsManager = RecordingsManager(
      recordingsDirectory: appDirs.recordingsDirectory,
      importsDirectory: appDirs.importsDirectory,
    );

    RecordingTranscriber recordingTranscriber = RecordingTranscriber();

    StreamTranscriber streamTranscriber = StreamTranscriber();

    return AppResources._(
      appDirs: appDirs,
      recordingsManager: recordingsManager,
      recordingTranscriber: recordingTranscriber,
      streamTranscriber: streamTranscriber,
    );
  }

  @override
  @protected
  Future<AppResources> onInitialize(Map<String, dynamic> args) async {
    recordingsManager.load();
    streamTranscriber.initialize();
    return this;
  }

  @override
  @protected
  Future<void> onTerminate() async {
    await streamTranscriber.terminate();
  }
}
