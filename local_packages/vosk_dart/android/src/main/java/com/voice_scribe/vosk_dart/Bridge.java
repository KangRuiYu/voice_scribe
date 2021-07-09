package com.voice_scribe.vosk_dart;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.MethodChannel;

// Object that connects a VoskInstance to method and event channels.
class Bridge {
    private static final String BASE_METHOD_CHANNEL_NAME = "vosk_method_";
    private static final String BASE_EVENT_CHANNEL_NAME = "vosk_event_";

    private final MethodChannel methodChannel; // The channel from which method calls are exchanged.
    private final EventChannel eventChannel; // The channel in which java sends events to dart.

    private final VoskMethodCallHandler voskMethodCallHandler;
    private final VoskStreamHandler voskStreamHandler;

    // Creates connections between the instance and the dart side via channels with the given id.
    public Bridge(VoskInstance voskInstance, BinaryMessenger binaryMessenger, long id) {
        methodChannel = new MethodChannel(
                binaryMessenger,
                BASE_METHOD_CHANNEL_NAME + String.valueOf(id)
        );
        eventChannel = new EventChannel(
                binaryMessenger,
                BASE_EVENT_CHANNEL_NAME + String.valueOf(id)
        );

        voskMethodCallHandler = new VoskMethodCallHandler(voskInstance);
        voskStreamHandler = new VoskStreamHandler();

        methodChannel.setMethodCallHandler(voskMethodCallHandler);
        eventChannel.setStreamHandler(voskStreamHandler);
    }

    // Close connections.
    public void close() {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    // Post events to the dart side.
    public void post(Object result) {
        EventSink eventSink = voskStreamHandler.getEventSink();

        if (eventSink != null) {
            eventSink.success(result);
        }
    }
}
