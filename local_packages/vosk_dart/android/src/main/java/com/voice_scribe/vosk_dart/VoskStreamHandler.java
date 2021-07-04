package com.voice_scribe.vosk_dart;

import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;

// Handles stream events when listeners start listening and/or canceling.
class VoskStreamHandler implements StreamHandler{
    private int listenerCount = 0;

    private EventSink eventSink;

    public EventSink getEventSink() {
        return eventSink;
    }

    @Override
    public void onListen(Object listener, EventSink eventSink) {
        if (++listenerCount == 1) {
            this.eventSink = eventSink;
        }
    }

    @Override
    public void onCancel(Object listener) {
        if (--listenerCount == 0) {
            this.eventSink = null;
        }
    }
}