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
import java.io.IOException;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

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
  private Future<Model> modelFuture;
  private ExecutorService executorService;

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

    // Opens up a new thread and opens the given transcription model in it.
    else if (call.method.equals("open")) {
      String modelPath = (String) call.arguments;
      executorService = Executors.newSingleThreadExecutor();
      modelFuture = executorService.submit(new OpenModel(modelPath));
      result.success(null);
    }

    // Queues a transcription task in the open thread.
    else if (call.method.equals("queueFileForTranscription")) {
      String filePath = call.argument("filePath");
      int sampleRate = call.argument("sampleRate");
      executorService.submit(new TranscribeFile(modelFuture, filePath, sampleRate));
      result.success(null);
    }

    // Frees existing threads and resources.
    else if (call.method.equals("close")) {
      executorService.submit(new CloseModel(modelFuture));
      executorService.shutdown();
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

// A task that is given to a thread. It opens a model at the given path,
// returning a future of the model.
class OpenModel implements Callable<Model> {
  private final String modelPath;

  public OpenModel(String modelPath) {
    this.modelPath = modelPath;
  }

  public Model call() {
    return new Model(modelPath);
  }
}

// A task that is given to a thread. It closes the given model future.
class CloseModel implements Runnable {
  private final Future<Model> modelFuture;

  public CloseModel(Future<Model> modelFuture) {
    this.modelFuture = modelFuture;
  }

  public void run() {
    try {
      modelFuture.get().close();
    }
    catch (ExecutionException | InterruptedException e) {
      System.out.println("Unable to finish opening the given model.");
    }
  }
}

// A task that is given to a thread. It transcribes the given file with the given model and
// sample rate. (Note: Some of the code was written with reference to the code examples in the
// Vosk api.
class TranscribeFile implements Runnable {
  private final Future<Model> modelFuture;
  private final String filePath;
  private final int sampleRate;

  public TranscribeFile(Future<Model> modelFuture, String filePath, int sampleRate) {
    this.modelFuture = modelFuture;
    this.filePath = filePath;
    this.sampleRate = sampleRate;
  }

  @Override
  public void run() {
    try (
      Recognizer recognizer = new Recognizer(modelFuture.get(), sampleRate);
      FileInputStream fileInputStream = new FileInputStream(filePath)
    ) {
      fileInputStream.skip(44); // Skip the 44 byte wav header.

      int bufferSize = Math.round(sampleRate * 0.4f);
      byte[] buffer = new byte[bufferSize];

      while (true) {
        int bytesRead = fileInputStream.read(buffer);

        if (bytesRead == -1) {
          break;
        }

        boolean silence = recognizer.acceptWaveForm(buffer, bytesRead);

        if (silence) {
        }
      }

      System.out.println(recognizer.getFinalResult());
    }
    catch (ExecutionException | InterruptedException e) {
      System.out.println("Unable to finish opening the given model.");
    }
    catch (FileNotFoundException e) {
      System.out.println("Wav file not found.");
    }
    catch (IOException e) {
      System.out.println("IO error, could not read contents of wav file.");
    }
  }
}
