package com.voice_scribe.vosk_dart;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

import org.vosk.Model;

// Encapsulates the resources and methods of a single Vosk running instance.
class VoskInstance {
    private Future<Model> modelFuture; // The model that will be used for transcribing.

    private final ExecutorService executorService; // The thread that will be used for transcribing.
    private final VoskStreamHandler streamHandler; // The stream handler, that contains the event sink where events are posted.

    public VoskInstance(ExecutorService executorService, VoskStreamHandler streamHandler) {
        this.executorService = executorService;
        this.streamHandler = streamHandler;
    }

    // Ask the thread to open up the model at the given path. Returns true if
    // queueing was successful.
    public boolean queueModelToBeOpened(String modelPath) {
        modelFuture = executorService.submit(new OpenModel(modelPath));
        return true;
    }

    // Ask the thread to transcribe the file at the given path. Returns true if queueing
    // was successful.
    public boolean queueFileForTranscription(String filePath, int sampleRate) {
        executorService.submit(new TranscribeFile(modelFuture, filePath, sampleRate, streamHandler.getEventSink()));
        return true;
    }

    // Asks the thread to close the existing model. Returns true if queueing was
    // was successful.
    public boolean queueModelToBeClosed() {
        executorService.submit(new CloseModel(modelFuture));
        return true;
    }
}
