package com.voice_scribe.vosk_dart;

import io.flutter.plugin.common.BinaryMessenger;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.vosk.Model;

// Encapsulates the resources and methods of a single Vosk running instance.
// Does not do any error checking, which is left up to the dart side.
class VoskInstance {
    private Future<Model> modelFuture; // The model that will be used for transcribing.
    private ExecutorService executorService; // Handles the thread that will be used for transcribing.
    private final Bridge bridge; // Used to communicate with dart.

    public VoskInstance(BinaryMessenger binaryMessenger, long id) {
        bridge = new Bridge(this, binaryMessenger, id);
    }

    // Allocate a single thread for computation. Make sure to deallocate when done.
    public void allocateSingleThread() {
        executorService = Executors.newSingleThreadExecutor();
    }

    // Deallocate the currently allocated thread. Will wait for all existing tasks to complete
    // before thread is closed.
    public void deallocateThread() {
        executorService.shutdown();
        executorService = null;
    }

    // Attempts to interrupt thread and close it.
    public void terminateThread() {
        executorService.shutdownNow();
        executorService = null;
    }

    // Ask the thread to open up the model at the given path.
    public void queueModelToBeOpened(String modelPath) {
        modelFuture = executorService.submit(new OpenModel(modelPath));
    }

    // Asks the thread to close the existing model.
    public void queueModelToBeClosed() {
        executorService.submit(new CloseModel(modelFuture));
        modelFuture = null;
    }

    // Ask the thread to transcribe the file at the given path.
    public void queueFileForTranscription(String filePath, String resultPath, int sampleRate) {
        executorService.submit(
                new TranscribeFile(filePath, resultPath, sampleRate, modelFuture, bridge)
        );
    }

    // Closes any used resources such as threads, models, and connections.
    // Instance will be unusable once closed.
    public void close() {
        if (modelFuture != null) {
            queueModelToBeClosed();
        }
        if (executorService != null) {
            deallocateThread();
        }
        bridge.close();
    }

    // Closes any used resources such as threads, models, and connections forcefully.
    // Instance will be unusable once closed.
    public void forceClose() {
        if (modelFuture != null) {
            queueModelToBeClosed();
        }
        if (executorService != null) {
            terminateThread();
        }
        bridge.close();
    }
}
