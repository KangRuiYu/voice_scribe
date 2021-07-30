package com.voice_scribe.vosk_dart;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.EventChannel.EventSink;

import java.util.concurrent.ExecutionException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.concurrent.Future;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.vosk.Model;
import org.vosk.Recognizer;

// A task that is given to a thread. It transcribes the given file with the given model and
// sample rate. (Note: Some of the code was written with reference to the code examples in the
// Vosk api.
class TranscribeFile implements Runnable {
    private final String filePath;
    private final String transcriptPath;
    private final int sampleRate;
    private final Future<Model> modelFuture;
    private final Bridge bridge;

    public TranscribeFile(
            String filePath,
            String transcriptPath,
            int sampleRate,
            Future<Model> modelFuture,
            Bridge bridge
    ) {
        this.filePath = filePath;
        this.transcriptPath = transcriptPath;
        this.sampleRate = sampleRate;
        this.modelFuture = modelFuture;
        this.bridge = bridge;
    }

    @Override
    public void run() {
        try (
                Recognizer recognizer = new Recognizer(modelFuture.get(), sampleRate);
                FileInputStream fileInput = new FileInputStream(filePath);
                PrintWriter transcriptOutput = new PrintWriter(transcriptPath, "UTF-8");
        ) {
            fileInput.skip(44); // Skip the 44 byte wav header.

            int bufferSize = Math.round(sampleRate * 0.4f);
            byte[] buffer = new byte[bufferSize];

            long bytesInFile = new File(filePath).length() - 44;
            long totalBytesRead = 0;

            Handler mainHandler = new Handler(Looper.getMainLooper());

            while (true) {
                // Terminate if interrupted. Deletes any leftover files.
                if (Thread.interrupted()) {
                    new File(transcriptPath).delete();
                    break;
                }

                int bytesRead = fileInput.read(buffer);

                if (bytesRead == -1) {
                    break;
                }
                else {
                    totalBytesRead += bytesRead;
                }

                if (bridge != null) {
                    final double result = (float) totalBytesRead / bytesInFile;
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            bridge.post(result);
                        }
                    });
                }

                boolean silence = recognizer.acceptWaveForm(buffer, bytesRead);

                if (silence) {
                    transcriptOutput.write(parseResultString(recognizer.getResult()));
                }
            }

            transcriptOutput.write(parseResultString(recognizer.getFinalResult()));
        }
        catch (ExecutionException | InterruptedException e) {
            System.out.println("Unable to finish opening the given model.");
        }
        catch (FileNotFoundException e) {
            System.out.println("Wav file not found.");
        }
        catch (IOException e) {
            System.out.println("IO error, could not read contents of wav file.");
        }
        catch (JSONException e) {
            System.out.println("Invalid JSON string given.");
        }
    }

    // Parses the given result string (JSON) into the proper format.
    // If the result is empty, an empty string is returned.
    // If given string is not a proper JSON string, a JSONException is thrown.
    private String parseResultString(String resultString) throws JSONException{
        JSONObject result = new JSONObject(resultString);

        if (!result.has("result")) { // Terminate if result is empty.
            return "";
        }

        JSONArray wordResults = result.getJSONArray("result");
        String parsedResultString = "";

        for (int i = 0; i < wordResults.length(); i++) {
            parsedResultString += parseWordResult(wordResults.getJSONObject(i));
        }

        return parsedResultString;
    }

    // Parses and returns the given word result JSON object as a formatted string.
    // If the given wordResult does not contain the proper data, a JSONException is thrown.
    private static String parseWordResult(JSONObject wordResult) throws JSONException{
         return wordResult.getString("word") + " " +
                String.valueOf(wordResult.getDouble("start")) + " " +
                String.valueOf(wordResult.getDouble("end")) + " " +
                String.valueOf(wordResult.getDouble("conf")) + "\n";
    }
}
