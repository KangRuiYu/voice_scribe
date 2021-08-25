package com.voice_scribe.vosk_dart;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

import org.vosk.Model;

// A task that is given to a thread. It closes the given model future.
class CloseModel implements Runnable {
    private final Future<Model> modelFuture;

    public CloseModel(Future<Model> modelFuture) {
        this.modelFuture = modelFuture;
    }

    @Override
    public void run() {
        try {
            modelFuture.get().close();
        }
        catch (ExecutionException | InterruptedException e) {
            System.out.println("Unable to finish opening the given model.");
        }
    }
}
