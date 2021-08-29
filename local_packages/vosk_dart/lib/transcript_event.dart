/// partial: Not finalized, what speech is inferred to be so far.
/// result: Finalized result.
/// finalResult: Finalized result and the last one for this transcript.
/// empty: Used to indicate an empty transcript event.
enum ResultType { partial, result, finalResult, empty }

/// none: No associated data type.
/// buffer: Was fed a buffer.
/// file: Was fed a file.
enum DataType { none, buffer, file }

class TranscriptEvent {
  final ResultType resultType;

  /// The data type associated with this event.
  ///
  /// Final results will not have an associated data type.
  final DataType dataType;

  /// The progress this event represents in a larger transcription task like of
  /// a file.
  ///
  /// Typically, buffer events will always have a progress of 1.0.
  final double progress;

  /// The transcript that is associated with this event.
  final String transcriptPath;

  /// The timestamp of this event.
  ///
  /// Partial results do not yet support timestamps and will instead have a
  /// negative time.
  final Duration timestamp;

  /// The text result so far.
  final String text;

  TranscriptEvent(Map event)
      : resultType = ResultType.values[event['resultType']],
        dataType = DataType.values[event['dataType']],
        progress = event['progress'],
        transcriptPath = event['transcriptPath'],
        timestamp = Duration(milliseconds: (event['timestamp'] * 1000).toInt()),
        text = event['text'];

  const TranscriptEvent.empty()
      : resultType = ResultType.empty,
        dataType = DataType.none,
        progress = 0,
        transcriptPath = '',
        timestamp = Duration.zero,
        text = '';

  @override
  String toString() {
    return '''
    {
      'resultType': $resultType,
      'dataType': $dataType,
      'progress': $progress,
      'transcriptPath': $transcriptPath,
      'timestamp': $timestamp,
      'text': $text,
    }
    ''';
  }
}
