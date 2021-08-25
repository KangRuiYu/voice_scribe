package com.voice_scribe.vosk_dart;

import android.os.Handler;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

import org.json.JSONException;
import org.json.JSONObject;
import org.vosk.Recognizer;

// Writes and posts the final result for the given recognizer to the
// given transcriptWriter and bridge.
//
// recognizer and transcriptWriter are closed afterwards.
class FinishTranscript extends TranscribeTask {
    public FinishTranscript(
            Future<Recognizer> recognizerFuture,
            TranscriptWriter transcriptWriter,
            Bridge bridge,
            Handler mainHandler
    ) {
        super(recognizerFuture, transcriptWriter, bridge, mainHandler);
    }

    @Override
    public void run() {
        try {
            Recognizer recognizer = recognizerFuture.get();

            JSONObject finalResult = new JSONObject(recognizer.getFinalResult());
            transcriptWriter.writeResult(finalResult);
            post(finalResult, FINAL_RESULT, NONE, 1.0);

            recognizer.close();
            transcriptWriter.close();
        }
        catch (ExecutionException | InterruptedException e) {
            System.out.println("Could not retrieve recognizer.");
        }
        catch (JSONException e) {
            System.out.println("Could not get valid JSON.");
        }
    }
}