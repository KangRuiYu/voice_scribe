package com.voice_scribe.vosk_dart;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.vosk.Model;

// Encapsulates the resources and methods of a single Vosk running instance.
// Does not do any error checking, which is left up to the dart side.
class VoskInstance {
    private final VoskStreamHandler streamHandler; // The stream handler, that contains the event sink where events are posted.

    private Future<Model> modelFuture; // The model that will be used for transcribing.
    private ExecutorService executorService; // The thread that will be used for transcribing.

    public VoskInstance(VoskStreamHandler streamHandler) {
        this.streamHandler = streamHandler;
    }

    // Allocate a single thread for computation. Make sure to deallocate when done.
    public void allocateSingleThread() {
        executorService = Executors.newSingleThreadExecutor();
    }

    // Deallocate the currently allocated thread.
    public void deallocateThread() {
        executorService.shutdown();
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
    public void queueFileForTranscription(String filePath, int sampleRate) {
        executorService.submit(new TranscribeFile(modelFuture, filePath, sampleRate, streamHandler.getEventSink()));
    }

    // Clean up any resources being used.
    public void clean() {
        if (executorService != null) {
            if (modelFuture != null) {
                queueModelToBeClosed();
            }
            deallocateThread();
        }
    }
}
