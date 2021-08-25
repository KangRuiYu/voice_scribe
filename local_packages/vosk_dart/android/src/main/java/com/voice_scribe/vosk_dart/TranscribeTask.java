package com.voice_scribe.vosk_dart;

import android.os.Handler;

import java.util.concurrent.Future;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.vosk.Recognizer;

// A transcription task given to a thread.
//
// Defines a set of properties and functions used commonly among transcription tasks.
abstract class TranscribeTask implements Runnable {
    // DataType Enums
    protected static final int NONE = 0;
    protected static final int BUFFER = 1;
    protected static final int FILE = 2;

    // ResultType Enums
    protected static final int PARTIAL = 0;
    protected static final int FULL = 1;
    protected static final int FINAL_FULL = 2;

    protected final Future<Recognizer> recognizerFuture; // For transcribing.
    protected final TranscriptWriter transcriptWriter; // For file writing.
    protected final Bridge bridge; // For dart communication.
    protected final Handler mainHandler; // For access to UI thread.

    protected TranscribeTask(
            Future<Recognizer> recognizerFuture,
            TranscriptWriter transcriptWriter,
            Bridge bridge,
            Handler mainHandler
    ) {
        this.recognizerFuture = recognizerFuture;
        this.transcriptWriter = transcriptWriter;
        this.bridge = bridge;
        this.mainHandler = mainHandler;
    }

    // Post the given transcription result in the UI thread to dart side.
    protected boolean post(
            JSONObject result,
            int dataType,
            int resultType,
            double progress
    ) throws JSONException {
        if (bridge == null) {
            return false;
        }

        final HashMap<String, Object> event = new HashMap<String, Object>();
        event.put("text", result.getString(resultType == PARTIAL ? "partial" : "text"));
        event.put("dataType", dataType);
        event.put("resultType", resultType);
        event.put("progress", progress);

        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                bridge.post(event);
            }
        });

        return true;
    }
}