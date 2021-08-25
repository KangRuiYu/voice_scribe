package com.voice_scribe.vosk_dart;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.HashMap;

/** VoskDartPlugin */
public class VoskDartPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel mainMethodChannel; // The main method channel used to communicate with dart.
    private FlutterPluginBinding flutterPluginBinding;
    private final HashMap<Long, VoskInstance> instances = new HashMap<Long, VoskInstance>();

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding;

        mainMethodChannel = new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(),
                "vosk_main"
        );
        mainMethodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        for (VoskInstance voskInstance : instances.values()) {
            voskInstance.closeResources(true);
            voskInstance.disconnect();
        }
        instances.clear();
        mainMethodChannel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("createNewInstance")) {
            long id = ((Number) call.arguments).longValue();
            createNewInstance(id);
            result.success(null);
        }
        else if (call.method.equals("removeInstance")) {
            long id = ((Number) call.arguments).longValue();
            removeInstance(id);
            result.success(null);
        }
        else {
            result.notImplemented();
        }
    }

    // Creates a new vosk instance with the given name and establishes a connection with it.
    // If an instance with the name exists, nothing happens.
    private void createNewInstance(long id) {
        VoskInstance newInstance = new VoskInstance(flutterPluginBinding.getBinaryMessenger(), id);
        instances.putIfAbsent(id, newInstance);
    }

    // Removes the instance with the given name. If no instance with the name exists, nothing
    // happens. Instance resources are not closed before removal.
    private void removeInstance(long id) {
        instances.remove(id);
    }
}
