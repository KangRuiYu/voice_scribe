package com.voice_scribe.vosk_dart;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.BinaryMessenger;

import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.vosk.Model;
import org.vosk.Recognizer;

// Encapsulates the resources and methods of a single Vosk running instance.
//
// Provides minimal functionality. Parameters are not checked for validity and the order of method
// calls is not enforced. These are instead done dart side where exceptions are more useful.
class VoskInstance {
    private final Bridge bridge; // Used to communicate with dart.
    private final Handler mainHandler; // Main thread.

    private ExecutorService executorService; // Current thread used for transcribing.
    private ExecutorService previousExecutorService; // Previous thread if any.

    private Future<Model> modelFuture; // The model that will be used for transcribing.

    private Future<Recognizer> recognizerFuture; // Recognizer used for transcribing.
    private TranscriptWriter transcriptWriter; // Used to write results to a output file.

    public VoskInstance(BinaryMessenger binaryMessenger, long id) {
        bridge = new Bridge(this, binaryMessenger, id);
        mainHandler = new Handler(Looper.getMainLooper());
    }

    // Allocate a single thread for computation.
    //
    // Will wait for any previous thread to finish before any task will execute.
    public void allocateSingleThread() {
        executorService = Executors.newSingleThreadExecutor();
        if (previousExecutorService != null) {
            executorService.submit(new WaitForThread(previousExecutorService));
        }
    }

    // Deallocate the current thread.
    //
    // Will wait for all existing tasks to complete before thread is closed.
    public void deallocateThread() {
        executorService.shutdown();
        previousExecutorService = executorService;
        executorService = null;
    }

    // Attempts to interrupt thread and close it.
    //
    // Sends an interrupt signal.
    public void terminateThread() {
        executorService.shutdownNow();
        previousExecutorService = executorService;
        executorService = null;
    }

    // Ask thread to open model at the given path.
    public void openModel(String modelPath) {
        modelFuture = executorService.submit(new OpenModel(modelPath));
    }

    // Asks the thread to close the existing model.
    public void closeModel() {
        executorService.submit(new CloseModel(modelFuture));
        modelFuture = null;
    }

    // Starts a new transcript file.
    //
    // Subsequent calls to feed functions will write to the given transcriptPath.
    // Will throw a FileNotFoundException if transcript file could not be found or created.
    // Will throw a UnsupportedEncodingException if charset is not supported on operating system.
    public void startNewTranscript(
            String transcriptPath, int sampleRate
    ) throws FileNotFoundException, UnsupportedEncodingException {
        recognizerFuture = executorService.submit(new CreateRecognizer(modelFuture, sampleRate));
        transcriptWriter = new TranscriptWriter(transcriptPath, "UTF-8");
    }

    // Terminate the current transcript.
    public void terminateTranscript() {
        executorService.submit(new CloseRecognizer(recognizerFuture));
        transcriptWriter.close();

        recognizerFuture = null;
        transcriptWriter = null;
    }

    // Finish the current transcript, writing/posting remaining results.
    //
    // If post is true, result events will be posted to dart side.
    public void finishTranscript(boolean post) {
        executorService.submit(new FinishTranscript(
                recognizerFuture,
                transcriptWriter,
                post ? bridge : null,
                mainHandler
        ));

        recognizerFuture = null;
        transcriptWriter = null;
    }

    // Feed the given file to the recognizer.
    //
    // If post is true, result events will be posted to dart side.
    public void feedFile(String filePath, boolean post) {
        executorService.submit(new TranscribeFile(
                filePath,
                recognizerFuture,
                transcriptWriter,
                post ? bridge : null,
                mainHandler
        ));
    }

    // Feed the given buffer to the recognizer.
    //
    // If post is true, result events will be posted to dart side.
    public void feedBuffer(byte[] buffer, boolean post) {
        executorService.submit(new TranscribeBuffer(
                buffer,
                recognizerFuture,
                transcriptWriter,
                post ? bridge : null,
                mainHandler
        ));
    }

    // Closes any open threads, recognizers, writers, and models.
    //
    // If force is true, existing thread will attempt to quit tasks to clear resources.
    // If force is false, resources will be cleared once existing thread has finished existing tasks.
    // If no thread is open to close resources, one will be allocated and shutdown when finished.
    public void closeResources(boolean force) {
        if (force && executorService != null) {
            terminateThread();
        }

        if (executorService == null) {
            allocateSingleThread();
        }

        if (recognizerFuture != null && transcriptWriter != null) {
            terminateTranscript();
        }
        if (modelFuture != null) {
            closeModel();
        }

        deallocateThread();
    }

    // Disconnects this instance from dart, rendering it unusable once called.
    public void disconnect() {
        bridge.close();
    }
}
