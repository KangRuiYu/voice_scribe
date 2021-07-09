package com.voice_scribe.vosk_dart;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.EventChannel.EventSink;

import java.util.concurrent.ExecutionException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.concurrent.Future;

import org.vosk.Model;
import org.vosk.Recognizer;

// A task that is given to a thread. It transcribes the given file with the given model and
// sample rate. (Note: Some of the code was written with reference to the code examples in the
// Vosk api.
class TranscribeFile implements Runnable {
    private final Future<Model> modelFuture;
    private final String filePath;
    private final int sampleRate;
    private final Bridge bridge;

    public TranscribeFile(
            Future<Model> modelFuture,
            String filePath,
            int sampleRate,
            Bridge bridge
    ) {
        this.modelFuture = modelFuture;
        this.filePath = filePath;
        this.sampleRate = sampleRate;
        this.bridge = bridge;
    }

    @Override
    public void run() {
        try (
                Recognizer recognizer = new Recognizer(modelFuture.get(), sampleRate);
                FileInputStream fileInputStream = new FileInputStream(filePath)
        ) {
            fileInputStream.skip(44); // Skip the 44 byte wav header.

            int bufferSize = Math.round(sampleRate * 0.4f);
            byte[] buffer = new byte[bufferSize];

            long bytesInFile = new File(filePath).length() - 44;
            long totalBytesRead = 0;

            Handler mainHandler = new Handler(Looper.getMainLooper());

            while (true) {
                int bytesRead = fileInputStream.read(buffer);

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
                }
            }

            System.out.println(recognizer.getFinalResult());
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
    }
}
