import 'dart:convert';
import 'dart:io';

/// Reads and parses information from the given [transcriptFile].
///
/// Returns the information in a [Map] with a stable order. Map will contain
/// pairs of start times and text.
/// If [transcriptFile] does not exist, throws [TranscriptDoesNotExists].
Future<Map<Duration, String>> read(File transcriptFile) async {
  if (!await transcriptFile.exists()) throw const TranscriptDoesNotExists();

  Map<Duration, String> parsedTranscript = {};
  Stream<String> linesStream = transcriptFile
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter());

  Duration currentStartTime = Duration.zero;
  String currentResult = '';

  await for (String line in linesStream) {
    if (line.isEmpty) {
      parsedTranscript[currentStartTime] = currentResult;
      currentStartTime = Duration.zero;
      currentResult = '';
    } else {
      List<String> parsedLine = line.split(' ');

      // If first line.
      if (currentStartTime == Duration.zero) {
        double milliseconds = double.parse(parsedLine[1]) * 1000;
        currentStartTime = Duration(milliseconds: milliseconds.toInt());
      }
      currentResult += parsedLine[0] + ' ';
    }
  }

  parsedTranscript[currentStartTime] = currentResult;

  return parsedTranscript;
}

class TranscriptDoesNotExists implements Exception {
  final String message;
  const TranscriptDoesNotExists([this.message]);
}
