import 'package:flutter/material.dart';

import '../../utils/formatter.dart' as formatter;
import '../../constants/theme_constants.dart' as theme_constants;

/// Widget displaying contents of a single transcription result.
class TranscriptResult extends StatelessWidget {
  final Duration timestamp;
  final String resultText;

  const TranscriptResult({
    this.timestamp = const Duration(seconds: -1),
    this.resultText = '',
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final String formattedTimestamp =
        timestamp.isNegative ? '--:--' : formatter.formatDuration(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: theme_constants.padding_large,
        vertical: theme_constants.padding_small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formattedTimestamp, style: textTheme.bodyText1),
          const SizedBox(height: theme_constants.padding_tiny),
          Text(resultText, style: textTheme.bodyText2),
        ],
      ),
    );
  }
}
