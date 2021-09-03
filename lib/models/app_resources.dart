import 'package:permission_handler/permission_handler.dart';
import 'package:voice_scribe/models/requirement_manager.dart';

import 'recording_transcriber.dart';
import 'recordings_manager.dart';
import 'stream_transcriber.dart';
import '../utils/app_dir.dart';

const String storage_requirement = 'Storage Permissions';
const String microphone_requirement = 'Microphone Permissions';

/// The state of a running app instance.
class VoiceScribeState {
  bool _onBootCalled = false;
  bool _onReadyCalled = false;

  AppDirs get appDirs => _appDirs;
  AppDirs _appDirs;

  RecordingsManager get recordingsManager => _recordingsManager;
  RecordingsManager _recordingsManager;

  RequirementsManager get requirementsManager => _requirementsManager;
  RequirementsManager _requirementsManager;

  RecordingTranscriber get recordingTranscriber => _recordingTranscriber;
  RecordingTranscriber _recordingTranscriber;

  StreamTranscriber get streamTranscriber => _streamTranscriber;
  StreamTranscriber _streamTranscriber;

  /// Should be called immediately on application boot.
  ///
  /// Creates the commonly required application resources and
  /// delete any temporary files if they exist.
  /// The created resources will only be available, not necessarily usable. Some
  /// require further initialization.
  /// Is idempotent.
  Future<void> onBoot() async {
    if (_onBootCalled) return;
    _onBootCalled = true;

    _appDirs = AppDirs(
      recordingsDirectory: defaultRecordingsDir(),
      modelsDirectory: await defaultModelDir(),
      importsDirectory: await defaultImportsDir(),
      tempDirectory: await defaultTempDir(),
    );
    _recordingsManager = RecordingsManager(
      recordingsDirectory: appDirs.recordingsDirectory,
      importsDirectory: appDirs.importsDirectory,
    );
    _requirementsManager = RequirementsManager({
      storage_requirement: Requirement<PermissionStatus>(
        updateFunction: () => Permission.storage.status,
        testFunction: (PermissionStatus p) => p == PermissionStatus.granted,
      ),
      microphone_requirement: Requirement<PermissionStatus>(
        updateFunction: () => Permission.microphone.status,
        testFunction: (PermissionStatus p) => p == PermissionStatus.granted,
      ),
    });
    _recordingTranscriber = RecordingTranscriber();
    _streamTranscriber = StreamTranscriber();

    await _requirementsManager.updateAll();
    await _deleteTemporaryDirectory();
  }

  /// Should be called when certain requirements have been met during
  /// runtime.
  ///
  /// Requirements:
  /// (1) AppResources is available, ie. onBoot was called and finished.
  /// (2) The application has permission to write/read from storage.
  /// (3) The application has permission to listen to the microphone.
  /// (4) The application has a model.
  ///
  /// Is idempotent.
  /// If onBoot has not finished, throws [OnBootHasNotFinished] error.
  Future<void> onReady() async {
    if (_onReadyCalled) return;
    if (_streamTranscriber == null) throw OnBootHasNotFinished();
    _onReadyCalled = true;

    await appDirs.createAll();
    recordingsManager.initialize();
    streamTranscriber.initialize();
  }

  /// Should be called before the application exits normally.
  ///
  /// Deletes any temporary files if they exist.
  /// Closes any resources if they exist.
  /// Can be safely called even when [onBoot] and [onReady] are called.
  Future<void> onExit() async {
    await Future.wait([
      _deleteTemporaryDirectory(),
      streamTranscriber?.terminate(),
    ]);
  }

  Future<void> _deleteTemporaryDirectory() async {
    if (await appDirs?.tempDirectory?.exists()) {
      await appDirs?.tempDirectory?.delete();
    }
  }
}

class OnBootHasNotFinished extends Error {
  final String message;
  OnBootHasNotFinished([this.message]);
}
