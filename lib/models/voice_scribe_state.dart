import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:voice_scribe/models/app_dir.dart';
import 'package:voice_scribe/models/recordings_manager.dart';
import 'package:voice_scribe/models/requirement_manager.dart';
import 'package:voice_scribe/models/transcript/recording_transcriber.dart';
import 'package:voice_scribe/models/transcript/stream_transcriber.dart';
import 'package:voice_scribe/utils/model_utils.dart' as model_utils;

const String storage_requirement = 'Storage Permissions';
const String microphone_requirement = 'Microphone Permissions';
const String model_requirement = 'Model Availability';

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
      model_requirement: Requirement<String>(
        updateFunction: () =>
            model_utils.firstModelIn(_appDirs.modelsDirectory),
        testFunction: (String modelPath) => modelPath.isNotEmpty,
      ),
    });
    _recordingTranscriber = RecordingTranscriber(_appDirs.modelsDirectory);
    _streamTranscriber = StreamTranscriber(_appDirs.modelsDirectory);

    await _requirementsManager.updateAll();
    await _deleteTemporaryDirectory();

    // Add missing vosk native license.
    String voskLicense = await rootBundle.loadString('licenses/vosk_api.txt');
    LicenseRegistry.addLicense(
      () => Stream.value(LicenseEntryWithLineBreaks(['vosk_api'], voskLicense)),
    );
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
    List<Future> tasks = [
      _deleteTemporaryDirectory(),
      streamTranscriber?.terminate(),
    ];

    for (FirebaseApp firebaseApp in Firebase.apps) {
      tasks.add(firebaseApp.delete());
    }

    await Future.wait(tasks);
  }

  Future<void> _deleteTemporaryDirectory() async {
    if (await appDirs?.tempDirectory?.exists()) {
      await appDirs?.tempDirectory?.delete(recursive: true);
    }
  }
}

class OnBootHasNotFinished extends Error {
  final String message;
  OnBootHasNotFinished([this.message]);
}
