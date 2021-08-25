package com.voice_scribe.vosk_dart;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

import org.vosk.Model;
import org.vosk.Recognizer;

// A task that is given to a thread. It opens a new recognizer from the given
// model future and sample rate.
class CreateRecognizer implements Callable<Recognizer> {
    private final Future<Model> modelFuture;
    private final int sampleRate;

    public CreateRecognizer(Future<Model> modelFuture, int sampleRate) {
        this.modelFuture = modelFuture;
        this.sampleRate = sampleRate;
    }

    @Override
    public Recognizer call() {
        try {
            Recognizer recognizer = new Recognizer(modelFuture.get(), sampleRate);
            recognizer.setWords(true);
            return recognizer;
        }
        catch (ExecutionException | InterruptedException e) {
            System.out.println("Unable to finish opening the given model.");
            return null;
        }
    }
}
