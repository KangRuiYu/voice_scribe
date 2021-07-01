package com.voice_scribe.vosk_dart;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.io.FileInputStream;
import java.io.FileNotFoundException;

import org.vosk.LibVosk;
import org.vosk.Model;
import org.vosk.Recognizer;
import org.vosk.android.RecognitionListener;
import org.vosk.android.SpeechStreamService;

/** VoskDartPlugin */
public class VoskDartPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "vosk_dart");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }

    else if (call.method.equals("transcribeWavFile")) {
      String modelPath = call.argument("modelPath");
      int sampleRate = call.argument("sampleRate");
      String filePath = call.argument("filePath");

      Thread t = new Thread(new WavTranscriber(modelPath, filePath, sampleRate));
      t.start();
    }

    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}

// Transcribes a wav file in another thread.
class WavTranscriber implements Runnable, RecognitionListener {
  final private String modelPath;
  final private String filePath;
  final private int sampleRate;

  private SpeechStreamService speechStreamService;
  private Recognizer recognizer;
  private Model model;

  public WavTranscriber(String argModelPath, String argFilePath, int argSampleRate) {
    modelPath = argModelPath;
    sampleRate = argSampleRate;
    filePath = argFilePath;
  }

  @Override
  public void run() {
    model = new Model(modelPath);
    recognizer = new Recognizer(model, sampleRate);

    try {
      FileInputStream fileInputStream = new FileInputStream(filePath);
      speechStreamService = new SpeechStreamService(recognizer, fileInputStream, sampleRate);
      speechStreamService.start(this);
    }
    catch (FileNotFoundException e) {
      clean();
      System.out.println("File not found.");
    }
  }

  // Callbacks for transcription results.
  @Override
  public void onPartialResult(String hypothesis) {
  }

  @Override
  public void onResult(String hypothesis) {
  }

  @Override
  public void onFinalResult(String hypothesis) {
    clean();
    System.out.println(hypothesis);
  }

  @Override
  public void onError(Exception exception) {
  }

  @Override
  public void onTimeout() {
  }

  private void clean() {
    if (speechStreamService != null) {
      speechStreamService.stop();
    }
    if (recognizer != null) {
      recognizer.close();
    }
    if (model != null) {
      model.close();
    }
  }
}
