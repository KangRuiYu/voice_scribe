package com.voice_scribe.vosk_dart;

import android.os.Handler;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

import org.json.JSONException;
import org.json.JSONObject;
import org.vosk.Recognizer;

// Transcribes the given buffer with the given recognizer.
//
// Writes the result to the given transcriptWriter and posts an event to
// the given bridge.
class TranscribeBuffer extends TranscribeTask {
    private final byte[] buffer;

    public TranscribeBuffer(
            byte[] buffer,
            Future<Recognizer> recognizerFuture,
            TranscriptWriter transcriptWriter,
            Bridge bridge,
            Handler mainHandler
    ) {
        super(recognizerFuture, transcriptWriter, bridge, mainHandler);
        this.buffer = buffer;
    }

    @Override
    public void run() {
        try {
            final Recognizer recognizer = recognizerFuture.get();

            boolean silence = recognizer.acceptWaveForm(buffer, buffer.length);

            if (silence) {
                JSONObject result = new JSONObject(recognizer.getResult());
                transcriptWriter.writeResult(result);
                post(result, BUFFER, FULL, 1.0);
            }
            else {
                JSONObject partialResult = new JSONObject(recognizer.getPartialResult());
                post(partialResult, BUFFER, PARTIAL, 1.0);
            }
        }
        catch (ExecutionException | InterruptedException e) {
            System.out.println("Unable to finish getting the given recognizer.");
        }
        catch (JSONException e) {
            System.out.println("Invalid JSON string given.");
        }
    }
}
