import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:voice_scribe/models/mixins/future_initializer.dart';
import 'package:vosk_dart/transcript_event.dart';

/// Keeps track of [TranscriptEvents] from an event stream and notifies
/// listeners when updated.
class TranscriptEventProvider extends ChangeNotifier with FutureInitializer {
  /// The history of result events received.
  UnmodifiableListView<TranscriptEvent> get resultEvents =>
      UnmodifiableListView<TranscriptEvent>(_resultEvents);
  final List<TranscriptEvent> _resultEvents = [];

  /// The number of completed results saved.
  int get resultCount => _resultEvents.length;

  /// The latest partial event received.
  TranscriptEvent get partialEvent => _partialEvent;
  TranscriptEvent _partialEvent = TranscriptEvent.empty();

  /// Internal subscription to the given [eventStream].
  ///
  /// Calls [_onEvent].
  StreamSubscription<TranscriptEvent> _eventSub;

  @override
  @protected
  Future<TranscriptEventProvider> onInitialize(Map<String, dynamic> args) {
    _eventSub = (args['eventStream'] as Stream<TranscriptEvent>).listen(
      _onEvent,
    );
    return Future.value(this);
  }

  @override
  @protected
  Future<void> onTerminate() async {
    await _eventSub.cancel();
  }

  @override
  void dispose() async {
    onTerminate();
    super.dispose();
  }

  /// Called on each newly received [TranscriptEvent].
  ///
  /// Updates [_partialEvent] and [_resultEvents] accordingly based on the
  /// [ResultType] of the received event.
  void _onEvent(TranscriptEvent event) {
    if (event.resultType == ResultType.partial) {
      _partialEvent = event;
    } else if (event.resultType == ResultType.result &&
        !event.timestamp.isNegative) {
      // If non-empty result.
      _resultEvents.add(event);
      _partialEvent = TranscriptEvent.empty();
    }
    notifyListeners();
  }
}
