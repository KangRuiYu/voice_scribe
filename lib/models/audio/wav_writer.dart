import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';

// Handles the writing of a wav file
class WavWriter {
  static final FlutterSoundHelper helper = FlutterSoundHelper();

  StreamSubscription<Food> _audioSubscription; // The sub to the audio data

  File _outputFile; // The file being written to
  IOSink _outputFileSink; // The IOStream of the output file

  bool _addedHeader = false;

  WavWriter({
    String outputPath,
    Stream<FoodData> audioStream,
  }) {
    _outputFile = File(outputPath);
    _outputFileSink = _outputFile.openWrite();

    _audioSubscription = audioStream.listen(
      (Food food) async {
        if (food is FoodData) {
          if (_addedHeader) {
            _outputFileSink.add(food.data);
          } else {
            var newBuffer =
                await helper.pcmToWaveBuffer(inputBuffer: food.data);
            _outputFileSink.add(
              newBuffer,
            );
            _addedHeader = true;
          }
        }
      },
    );
  }

  // Ends the output stream, returning the final wav file.
  Future<File> close() async {
    await _audioSubscription.cancel();
    await _outputFileSink.flush();
    await _outputFileSink.close();
    await _updateWavHeaderByteInfo();
    return _outputFile;
  }

  // Updates the recorded byte length of the data in the wav header of the file.
  Future<void> _updateWavHeaderByteInfo() async {
    RandomAccessFile fileAccess = await _outputFile.open(mode: FileMode.append);
    await fileAccess.setPosition(41);

    Uint8List intAsByteBuffer = Uint8List(4);
    intAsByteBuffer.buffer.asByteData().setInt32(
          0,
          fileAccess.lengthSync() - 44,
          Endian.little,
        );

    await fileAccess.writeFrom(intAsByteBuffer);

    fileAccess.close();
  }
}
