package com.voice_scribe.vosk_dart;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

import org.vosk.Recognizer;

// A task given to a thread. Closes the given recognizer future.
class CloseRecognizer implements Runnable {
    private final Future<Recognizer> recognizerFuture;

    public CloseRecognizer(Future<Recognizer> recognizerFuture) {
        this.recognizerFuture = recognizerFuture;
    }

    @Override
    public void run() {
        try {
            recognizerFuture.get().close();
        }
        catch (ExecutionException | InterruptedException e) {
            System.out.println("Unable to finish opening the given recognizer.");
        }
    }
}
