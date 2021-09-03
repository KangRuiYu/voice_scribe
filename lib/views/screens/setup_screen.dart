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
                title: storage_requirement,
                body: _storage_permission_description,
                status: requirementsManager.value(storage_requirement),
                onGrant: () async {
                  await Permission.storage.request();
                  await requirementsManager.updateAllAndNotify();
                },
              ),
              _PermissionCard(
                title: microphone_requirement,
                body: _microphone_permission_description,
                status: requirementsManager.value(microphone_requirement),
                onGrant: () async {
                  await Permission.microphone.request();
                  await requirementsManager.updateAllAndNotify();
                },
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
  final String title;
  final String body;
  final PermissionStatus status;
  final Function onGrant;

  const _PermissionCard({
    @required this.title,
    @required this.body,
    @required this.status,
    @required this.onGrant,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget button;
    if (status == PermissionStatus.granted) {
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
        onPressed: onGrant,
      );
    }

    return _CardSection(
      title: title,
      children: [
        Text(body, style: theme.textTheme.bodyText2),
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
