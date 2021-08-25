package com.voice_scribe.vosk_dart;

import android.os.Handler;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

import org.json.JSONException;
import org.json.JSONObject;
import org.vosk.Recognizer;

// Transcribes the file at the given filePath with the given recognizer.
//
// Writes the result to the given transcriptWriter and posts an event to
// the given bridge.
class TranscribeFile extends TranscribeTask {
    private static final int BUFFER_SIZE = 6400;

    private final String filePath;

    public TranscribeFile(
            String filePath,
            Future<Recognizer> recognizerFuture,
            TranscriptWriter transcriptWriter,
            Bridge bridge,
            Handler mainHandler
    ) {
        super(recognizerFuture, transcriptWriter, bridge, mainHandler);
        this.filePath = filePath;
    }

    @Override
    public void run() {
        try (FileInputStream fileInput = new FileInputStream(filePath)) {
            fileInput.skip(44); // Skip the 44 byte wav header.

            byte[] buffer = new byte[BUFFER_SIZE];

            long bytesInFile = new File(filePath).length() - 44;
            long totalBytesRead = 0;

            Recognizer recognizer = recognizerFuture.get();

            while (true) {
                int bytesRead = fileInput.read(buffer);

                if (bytesRead == -1) {
                    break;
                }
                else {
                    totalBytesRead += bytesRead;
                }

                if (Thread.interrupted()) {
                    break;
                }

                boolean silence = recognizer.acceptWaveForm(buffer, bytesRead);

                double progress = (float) totalBytesRead / bytesInFile;

                if (silence) {
                    JSONObject result = new JSONObject(recognizer.getResult());
                    transcriptWriter.writeResult(result);
                    post(result, RESULT, FILE, progress);
                }
                else {
                    JSONObject partialResult = new JSONObject(recognizer.getPartialResult());
                    post(partialResult, PARTIAL, FILE, progress);
                }
            }
        }
        catch (ExecutionException | InterruptedException e) {
            System.out.println("Unable to finish opening the given model.");
        }
        catch (IOException e) {
            System.out.println("IO error, could not read contents of wav file.");
        }
        catch (JSONException e) {
            System.out.println("Invalid JSON string given.");
        }
    }
}
