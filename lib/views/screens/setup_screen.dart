import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:voice_scribe/views/screens/main_screen.dart';

import '../../models/voice_scribe_state.dart';
import '../../models/requirement_manager.dart';
import '../../utils/theme_constants.dart' as themeConstants;

const String _storage_permission_description =
    'Used to read and write recordings onto your phone\'s storage.';
const String _microphone_permission_description =
    'Used to listen and record audio from your phone\'s microphone.';

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
        padding: const EdgeInsets.all(themeConstants.padding_tiny),
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
        const SizedBox(height: themeConstants.padding_small),
        Align(alignment: Alignment.centerRight, child: button),
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
        left: themeConstants.padding_small,
        right: themeConstants.padding_small,
        top: themeConstants.padding_small,
      ),
      child: Padding(
        padding: const EdgeInsets.all(themeConstants.padding_large),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: Theme.of(context).textTheme.subtitle2),
            ),
            const SizedBox(height: themeConstants.padding_medium),
            const Divider(),
            const SizedBox(height: themeConstants.padding_medium),
            ...children,
          ],
        ),
      ),
    );
  }
}

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
