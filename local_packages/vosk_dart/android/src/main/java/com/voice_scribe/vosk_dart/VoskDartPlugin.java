package com.voice_scribe.vosk_dart;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.io.FileInputStream;

import org.vosk.LibVosk;
import org.vosk.LogLevel;
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
  private Model model;
  private Recognizer recognizer;

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

    // Open the Vosk API with the given model and sample rate.
    else if (call.method.equals("open")) {
      String modelPath = (String) call.argument("modelPath");
      int sampleRate = (int) call.argument("sampleRate");

      model = new Model(modelPath);
      recognizer = new Recognizer(model, sampleRate);
      result.success(null);
    }

    // Turns debug mode on or off. Option changes the amount of output
    // into the console.
    else if (call.method.equals("setDebug")) {
      boolean on = (boolean) call.arguments;

      if (on) {
        LibVosk.setLogLevel(LogLevel.INFO);
      }
      else {
        LibVosk.setLogLevel(LogLevel.WARNINGS);
      }
      result.success(null);
    }

    // Feeds audio buffer to the Vosk in the form of a byte array.
    else if (call.method.equals("feedAudioBuffer")) {
      byte[] byteBuffer = (byte[]) call.arguments;
      recognizer.acceptWaveForm(byteBuffer, byteBuffer.length);
      result.success(null);
    }

    // Feeds the audio data of a wav file into the transcriber.
    else if (call.method.equals("feedWavFile")) {
//      String filePath = (String) call.arguments;
//      FileInputStream fileInputStream = FileInputStream(filePath);
      result.success(null);
    }

    // Returns the current transcription results.
    else if (call.method.equals("getPartialResult")) {
      result.success(recognizer.getPartialResult());
    }

    // Gets the final result of transcribing the fed audio data.
    else if (call.method.equals("getFinalResult")) {
      result.success(recognizer.getFinalResult());
    }

    // Cleans up.
    else if (call.method.equals("close")) {
      model.close();
      result.success(null);
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
