package com.voice_scribe.deep_speech_dart;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;

import org.mozilla.deepspeech.libdeepspeech.DeepSpeechModel;
import org.mozilla.deepspeech.libdeepspeech.Metadata;
import org.mozilla.deepspeech.libdeepspeech.CandidateTranscript;
import org.mozilla.deepspeech.libdeepspeech.TokenMetadata;
import org.mozilla.deepspeech.libdeepspeech.DeepSpeechStreamingState;

/** DeepSpeechDartPlugin */
public class DeepSpeechDartPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private DeepSpeechModel model;
  private DeepSpeechStreamingState streamState;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "deep_speech_dart");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }
    else if (call.method.equals("initialize")) {
      initialize((String) call.arguments);
      result.success(null);
    }
    else if (call.method.equals("beamWidth")) {
      result.success(beamWidth());
    }
    else if (call.method.equals("setBeamWidth")) {
      setBeamWidth((long) call.arguments);
      result.success(null);
    }
    else if (call.method.equals("sampleRate")) {
      result.success(sampleRate());
    }
    else if (call.method.equals("enableExternalScorer")) {
      enableExternalScorer((String) call.arguments);
      result.success(null);
    }
    else if (call.method.equals("disableExternalScorer")) {
      disableExternalScorer();
      result.success(null);
    }
    else if (call.method.equals("setScorerAlphaBeta")) {
      setScorerAlphaBeta((float) call.argument("alpha"), (float) call.argument("beta"));
      result.success(null);
    }
    else if (call.method.equals("sttWithMetadata")) {
      result.success(
        metadataToArrayList(
          sttWithMetadata(
            (byte[]) call.argument("byteBuffer"), (int) call.argument("maxResults")
          )
        )
      );
    }
    else if (call.method.equals("feedAudioContent")) {
      feedAudioContent((byte[]) call.arguments);
      result.success(null);
    }
    else if (call.method.equals("intermediateDecode")) {
      result.success(intermediateDecode());
    }
    else if (call.method.equals("intermediateDecodeWithMetadata")) {
      result.success(metadataToArrayList(intermediateDecodeWithMetadata((int) call.arguments)));
    }
    else if (call.method.equals("addHotWord")) {
      addHotWord((String) call.argument("word"), (float) call.argument("boost"));
      result.success(null);
    }
    else if (call.method.equals("eraseHotWord")) {
      eraseHotWord((String) call.arguments);
      result.success(null);
    }
    else if (call.method.equals("clearHotWords")) {
      clearHotWords();
      result.success(null);
    }
    else if (call.method.equals("finish")) {
      result.success(finish());
    }
    else if (call.method.equals("finishWithMetadata")) {
      result.success(metadataToArrayList(finishWithMetadata((int) call.arguments)));
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void initialize(String modelPath) {
    model = new DeepSpeechModel(modelPath);
    streamState = model.createStream();
  }

  private long beamWidth() {
    return model.beamWidth();
  }

  private void setBeamWidth(long beamWidth) {
    model.setBeamWidth(beamWidth);
  }

  private int sampleRate() {
    return model.sampleRate();
  }

  private void enableExternalScorer(String scorer) {
    model.enableExternalScorer(scorer);
  }

  private void disableExternalScorer() {
    model.disableExternalScorer();
  }

  private void setScorerAlphaBeta(float alpha, float beta) {
    model.setScorerAlphaBeta(alpha, beta);
  }

  private Metadata sttWithMetadata(byte[] byteBuffer, int maxResults) {
    short[] shortBuffer = byteToShortArray(byteBuffer);
    return model.sttWithMetadata(shortBuffer, shortBuffer.length, maxResults);
  }

  private void feedAudioContent(byte[] byteBuffer) {
    short[] shortBuffer = byteToShortArray(byteBuffer);
    model.feedAudioContent(streamState, shortBuffer, shortBuffer.length);
  }

  private String intermediateDecode() {
    return model.intermediateDecode(streamState);
  }

  private Metadata intermediateDecodeWithMetadata(int maxResults) {
    return model.intermediateDecodeWithMetadata(streamState, maxResults);
  }

  private void addHotWord(String word, float boost) {
    model.addHotWord(word, boost);
  }

  private void eraseHotWord(String word) {
    model.eraseHotWord(word);
  }

  private void clearHotWords() {
    model.clearHotWords();
  }

  private String finish() {
    // Finish remaining calculations, freeing resources, and returning the result.
    String result = model.finishStream(streamState);
    model.freeModel();
    return result;
  }

  private Metadata finishWithMetadata(int maxResults) {
    Metadata result = model.finishStreamWithMetadata(streamState, maxResults);
    model.freeModel();
    return result;
  }

  private short[] byteToShortArray(byte[] byteBuffer) {
    short[] shortBuffer = new short[byteBuffer.length / 2];

    for (int i = 0; i < shortBuffer.length; i++) {
        shortBuffer[i] = (short) ((byteBuffer[i * 2 + 1] << 8) | (byteBuffer[i * 2] & 0xFF));
    }

    return shortBuffer;
  }

  private ArrayList<HashMap<String, Object>> metadataToArrayList(Metadata metadata) {
    ArrayList<HashMap<String, Object>> metadataList = new ArrayList<HashMap<String, Object>>();

    for (int i = 0; i < metadata.getNumTranscripts(); i++) {
      metadataList.add(candidateTranscriptToMap(metadata.getTranscript(i)));
    }

    return metadataList;
  }

  private HashMap<String, Object> candidateTranscriptToMap(CandidateTranscript transcript) {
    HashMap<String, Object> transcriptMap = new HashMap<String, Object>();
    transcriptMap.put("confidence", transcript.getConfidence());

    ArrayList<HashMap<String, Object>> tokens = new ArrayList<HashMap<String, Object>>();
    for (int i = 0; i < transcript.getNumTokens(); i++) {
      tokens.add(tokenMetadataToMap(transcript.getToken(i)));
    }
    transcriptMap.put("tokens", tokens);

    return transcriptMap;
  }

  private HashMap<String, Object> tokenMetadataToMap(TokenMetadata token) {
    HashMap<String, Object> tokenMap = new HashMap<String, Object>();
    tokenMap.put("text", token.getText());
    tokenMap.put("timestep", token.getTimestep());
    tokenMap.put("startTime", token.getStartTime());
    return tokenMap;
  }
}
