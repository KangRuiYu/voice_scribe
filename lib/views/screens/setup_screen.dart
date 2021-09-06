import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'main_screen.dart';
import '../../models/model_downloader.dart';
import '../../models/requirement_manager.dart';
import '../../models/voice_scribe_state.dart';
import '../../utils/app_dir.dart';
import '../../utils/file_utils.dart' as file_dir_generator;
import '../../utils/file_extensions.dart' as file_extensions;
import '../../utils/model_utils.dart' as model_utils;
import '../../utils/theme_constants.dart' as theme_constants;

const String _storage_permission_description =
    'Used to read and write recordings onto your phone\'s storage.';
const String _microphone_permission_description =
    'Used to listen and record audio from your phone\'s microphone.';
const String _model_permission_description =
    'Models are the files used to recognize speech.';

/// Provides options for user to grant permissions and download model.
class SetupScreen extends StatelessWidget {
  const SetupScreen();

  @override
  Widget build(BuildContext context) {
    RequirementsManager requirementsManager =
        context.watch<RequirementsManager>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Setup')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _PermissionCard(
                permissionName: storage_requirement,
                reason: _storage_permission_description,
                permission: Permission.storage,
                requirementsManager: requirementsManager,
              ),
              _PermissionCard(
                permissionName: microphone_requirement,
                reason: _microphone_permission_description,
                permission: Permission.microphone,
                requirementsManager: requirementsManager,
              ),
              _ModelCard(requirementsManager.satisfied(model_requirement)),
              const SizedBox(height: theme_constants.padding_small),
            ],
          ),
        ),
        floatingActionButton: requirementsManager.allSatisfied()
            ? ElevatedButton(
                child: const Text('Continue'),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MainScreen()),
                ),
              )
            : null,
      ),
    );
  }
}

/// A card that displays a single permission and its current status.
///
/// Provides a button to grant said permissions.
class _PermissionCard extends StatelessWidget {
  final String permissionName;
  final String reason;

  final Permission permission;
  final RequirementsManager requirementsManager;

  const _PermissionCard({
    @required this.permissionName,
    @required this.reason,
    @required this.permission,
    @required this.requirementsManager,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final PermissionStatus status = requirementsManager.value(permissionName);

    Widget button;
    if (status.isGranted) {
      button = Padding(
        padding: const EdgeInsets.all(theme_constants.padding_tiny),
        child: Text(
          'Granted',
          style: theme.textTheme.bodyText1.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
      );
    } else {
      button = ElevatedButton(
        child: const Text('Grant'),
        onPressed: () async {
          PermissionStatus newStatus = await permission.request();
          if (newStatus.isPermanentlyDenied) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return _DeniedPermissionAlert();
              },
            );
          }
          await requirementsManager.updateAllAndNotify();
        },
      );
    }

    return _CardSection(
      title: permissionName,
      children: [
        Text(reason, style: theme.textTheme.bodyText2),
        const SizedBox(height: theme_constants.padding_large),
        Align(alignment: Alignment.centerRight, child: button),
      ],
    );
  }
}

/// Card that displays current model status and provides options based on it.
///
/// If user has no model, will provide an option to download one.
/// If user is retrieving a model, will display ongoing progress.
class _ModelCard extends StatelessWidget {
  final bool hasModel;
  final ModelDownloader modelDownloader = ModelDownloader();

  _ModelCard(this.hasModel);

  Future<void> _downloadModel(BuildContext context) async {
    AppDirs appDirs = context.read<AppDirs>();

    final String modelName = model_utils.supportedModels[0] + '.zip';
    final File downloadFile = file_dir_generator.fileIn(
      parentDirectory: appDirs.tempDirectory,
      name: file_dir_generator.uniqueName(),
      extension: file_extensions.temp,
    );
    final Directory unzipDir = file_dir_generator.directoryIn(
      parentDirectory: appDirs.tempDirectory,
      name: file_dir_generator.uniqueName(),
    );
    final Directory saveDir = file_dir_generator.directoryIn(
      parentDirectory: appDirs.modelsDirectory,
      name: model_utils.supportedModels[0],
    );

    await modelDownloader.download(
      modelName: modelName,
      downloadPath: downloadFile.path,
      unzipPath: unzipDir.path,
      savePath: saveDir.path,
    );

    await context.read<RequirementsManager>().updateAllAndNotify();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: modelDownloader,
      child: Selector<ModelDownloader, DownloadState>(
        selector: (BuildContext _, ModelDownloader m) => m.state,
        builder: (BuildContext ctx, DownloadState state, Widget _) {
          if (state == DownloadState.downloading) {
            return const _DownloadingModelCard();
          } else if (state == DownloadState.unzipping) {
            return const _UnZippingModelCard();
          } else if (hasModel) {
            return const _HasModelCard();
          } else {
            return _NoModelCard(onDownload: () => _downloadModel(context));
          }
        },
      ),
    );
  }
}

class _HasModelCard extends StatelessWidget {
  const _HasModelCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return _CardSection(
      title: model_requirement,
      children: [
        Text(
          _model_permission_description,
          style: theme.textTheme.bodyText2,
        ),
        const SizedBox(height: theme_constants.padding_large),
        Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(theme_constants.padding_small),
          child: Text(
            'Model found',
            style: theme.textTheme.bodyText1.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoModelCard extends StatelessWidget {
  final VoidCallback onDownload;

  const _NoModelCard({@required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return _CardSection(
      title: model_requirement,
      children: [
        Text(
          _model_permission_description,
          style: textTheme.bodyText2,
        ),
        const SizedBox(height: theme_constants.padding_large),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('No models found', style: textTheme.caption),
            const SizedBox(width: theme_constants.padding_large),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                child: const Text('Download model'),
                onPressed: onDownload,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DownloadingModelCard extends StatelessWidget {
  const _DownloadingModelCard();

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: model_requirement,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '(1/2) Downloading',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        const SizedBox(height: theme_constants.padding_large),
        Selector<ModelDownloader, double>(
          selector: (BuildContext _, ModelDownloader m) => m.progress,
          builder: (BuildContext ctx, double progress, Widget _) {
            return LinearProgressIndicator(value: progress);
          },
        ),
        const SizedBox(height: theme_constants.padding_large),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () => context.read<ModelDownloader>().cancel(),
          ),
        ),
      ],
    );
  }
}

class _UnZippingModelCard extends StatelessWidget {
  const _UnZippingModelCard();

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: model_requirement,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '(2/2) Unzipping',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        const SizedBox(height: theme_constants.padding_large),
        Selector(
          selector: (BuildContext _, ModelDownloader m) => m.progress,
          builder: (BuildContext ctx, double progress, Widget _) {
            return LinearProgressIndicator(value: progress);
          },
        ),
      ],
    );
  }
}

/// A card that contains a subsection of content.
class _CardSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CardSection({
    @required this.title,
    @required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        left: theme_constants.padding_small,
        right: theme_constants.padding_small,
        top: theme_constants.padding_small,
      ),
      child: Padding(
        padding: const EdgeInsets.all(theme_constants.padding_large),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: Theme.of(context).textTheme.subtitle2),
            ),
            const SizedBox(height: theme_constants.padding_medium),
            const Divider(),
            const SizedBox(height: theme_constants.padding_medium),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Shown when user has permanently denied a permission.
///
/// Prompts user to be redirected to app settings, where permission can be
/// manually granted.
class _DeniedPermissionAlert extends StatelessWidget {
  const _DeniedPermissionAlert();

  @override
  Widget build(BuildContext context) {
    final String bodyText = 'You have permanently denied this permission ' +
        'which is required for this application to function. The permission ' +
        'must be granted through the settings app.';

    return AlertDialog(
      title: const Text('Denied permission'),
      content: SingleChildScrollView(
        child: ListBody(children: [Text(bodyText)]),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Open settings'),
          onPressed: () {
            openAppSettings();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
