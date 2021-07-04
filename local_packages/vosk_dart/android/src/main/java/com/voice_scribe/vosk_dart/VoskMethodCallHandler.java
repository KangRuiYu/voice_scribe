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
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        }
        else if (call.method.equals("queueModelToBeOpened")) {
            String modelPath = (String) call.arguments;
            if (voskInstance.queueModelToBeOpened(modelPath)) {
                result.success(null);
            }
            else {
                result.error("ModelError", "Could not queue model to be opened.", null);
            }
        }
        else if (call.method.equals("queueFileForTranscription")) {
            String filePath = call.argument("filePath");
            int sampleRate = call.argument("sampleRate");
            if (voskInstance.queueFileForTranscription(filePath, sampleRate)) {
                result.success(null);
            }
            else {
                result.error("TranscriptionError", "Could not queue file to be transcribed.", null);
            }
        }
        else if (call.method.equals("queueModelToBeClosed")) {
            if (voskInstance.queueModelToBeClosed()) {
                result.success(null);
            }
            else {
                result.error("ModelError", "Could not queue model to be closed.", null);
            }
        }
        else {
            result.notImplemented();
        }
    }
}
