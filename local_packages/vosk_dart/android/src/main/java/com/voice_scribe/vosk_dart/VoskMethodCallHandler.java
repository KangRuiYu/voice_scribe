package com.voice_scribe.vosk_dart;

import androidx.annotation.NonNull;

import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

// Handles dart side method calls. Delegates calls to its Vosk instance.
class VoskMethodCallHandler implements MethodCallHandler {
    private final VoskInstance voskInstance;

    public VoskMethodCallHandler(VoskInstance voskInstance) {
        this.voskInstance = voskInstance;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("allocateSingleThread")) {
            voskInstance.allocateSingleThread();
            result.success(null);
        }
        else if (call.method.equals("deallocateThread")) {
            voskInstance.deallocateThread();
            result.success(null);
        }
        else if (call.method.equals("terminateThread")) {
            voskInstance.terminateThread();
            result.success(null);
        }
        else if (call.method.equals("openModel")) {
            String modelPath = (String) call.arguments;
            voskInstance.openModel(modelPath);
            result.success(null);
        }
        else if (call.method.equals("closeModel")) {
            voskInstance.closeModel();
            result.success(null);
        }
        else if (call.method.equals("startNewTranscript")) {
            try {
                String transcriptPath = call.argument("transcriptPath");
                int sampleRate = call.argument("sampleRate");
                voskInstance.startNewTranscript(transcriptPath, sampleRate);
                result.success(null);
            }
            catch (FileNotFoundException | UnsupportedEncodingException e) {
                result.error("FileError", "Transcript could not be created or accessed", null);
            }
        }
        else if (call.method.equals("terminateTranscript")) {
            voskInstance.terminateTranscript();
            result.success(null);
        }
        else if (call.method.equals("finishTranscript")) {
            boolean post = (boolean) call.arguments;
            voskInstance.finishTranscript(post);
            result.success(null);
        }
        else if (call.method.equals("feedFile")) {
            String filePath = call.argument("filePath");
            boolean post = call.argument("post");
            voskInstance.feedFile(filePath, post);
            result.success(null);
        }
        else if (call.method.equals("feedBuffer")) {
            byte[] buffer = call.argument("buffer");
            boolean post = call.argument("post");
            voskInstance.feedBuffer(buffer, post);
            result.success(null);
        }
        else if (call.method.equals("closeResources")) {
            boolean force = (boolean) call.arguments;
            voskInstance.closeResources(force);
            result.success(null);
        }
        else if (call.method.equals("disconnect")) {
            voskInstance.disconnect();
            result.success(null);
        }
        else {
            result.notImplemented();
        }
    }
}
