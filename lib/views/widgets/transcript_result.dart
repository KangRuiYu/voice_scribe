import 'package:flutter/material.dart';

import '../../utils/formatter.dart' as formatter;
import '../../utils/theme_constants.dart' as themeConstants;

/// Widget displaying contents of a single transcription result.
class TranscriptResult extends StatelessWidget {
  final String timestamp;
  final String resultText;

  /// Construct result given strings.
  const TranscriptResult({
    @required this.timestamp,
    @required this.resultText,
  });

  /// Construct result but with the timestamp generated using given [Duration].
  TranscriptResult.duration({
    @required Duration timestampDuration,
    @required this.resultText,
  }) : timestamp = formatter.formatDuration(timestampDuration);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: themeConstants.padding_large,
        vertical: themeConstants.padding_small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(timestamp, style: textTheme.bodyText1),
          const SizedBox(height: themeConstants.padding_tiny),
          Text(resultText, style: textTheme.bodyText2),
        ],
      ),
    );
  }
}
