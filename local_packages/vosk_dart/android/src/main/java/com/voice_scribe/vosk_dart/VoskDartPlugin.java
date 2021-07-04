package com.voice_scribe.vosk_dart;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;

/** VoskDartPlugin */
public class VoskDartPlugin implements FlutterPlugin {
  private ExecutorService executorService; // The background thread.

  private VoskStreamHandler voskStreamHandler; // Handles stream listen events.
  private VoskInstance voskInstance; // Encapsulates a single vosk instance.
  private VoskMethodCallHandler voskMethodCallHandler; // Handles method calls from dart to native.

  private MethodChannel methodChannel; // The channel from which method calls are exchanged.
  private EventChannel eventChannel; // The channel in which java sends events to  dart.

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    executorService = Executors.newSingleThreadExecutor();
    voskStreamHandler = new VoskStreamHandler();
    voskInstance = new VoskInstance(executorService, voskStreamHandler);
    voskMethodCallHandler = new VoskMethodCallHandler(voskInstance);

    methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "vosk_dart");
    methodChannel.setMethodCallHandler(voskMethodCallHandler);

    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "vosk_stream");
    eventChannel.setStreamHandler(voskStreamHandler);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    eventChannel.setStreamHandler(null);
    methodChannel.setMethodCallHandler(null);

    voskMethodCallHandler = null;
    voskInstance.queueModelToBeClosed();
    voskInstance = null;
    voskStreamHandler = null;

    executorService.shutdown();
  }
}
