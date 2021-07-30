package com.voice_scribe.vosk_dart;

import androidx.annotation.NonNull;

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
        else if (call.method.equals("deallocateSingleThread")) {
            voskInstance.deallocateThread();
            result.success(null);
        }
        else if (call.method.equals("terminateThread")) {
            voskInstance.terminateThread();
            result.success(null);
        }
        else if (call.method.equals("queueModelToBeOpened")) {
            String modelPath = (String) call.arguments;
            voskInstance.queueModelToBeOpened(modelPath);
            result.success(null);
        }
        else if (call.method.equals("queueModelToBeClosed")) {
            voskInstance.queueModelToBeClosed();
            result.success(null);
        }
        else if (call.method.equals("queueFileForTranscription")) {
            String filePath = call.argument("filePath");
            String transcriptPath = call.argument("transcriptPath");
            int sampleRate = call.argument("sampleRate");
            voskInstance.queueFileForTranscription(filePath, transcriptPath, sampleRate);
            result.success(null);
        }
        else if (call.method.equals("close")) {
            voskInstance.close();
            result.success(null);
        }
        else if (call.method.equals("forceClose")) {
            voskInstance.forceClose();
            result.success(null);
        }
        else {
            result.notImplemented();
        }
    }
}
