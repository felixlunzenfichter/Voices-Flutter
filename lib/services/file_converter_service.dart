import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:wave_generator/wave_generator.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class FileConverterService {
  File editedAudioFile;
  final FlutterFFmpeg _flutterFfmpeg = new FlutterFFmpeg();

  createAudioFileChunkFromFile(
      {@required File file,
      @required int startInSec,
      @required int endInSec}) async {
    String path = file.parent.path + "/first_try_audio_cut.wav";
    File newFile = File(path);
    if (await newFile.exists()) {
      await newFile.delete();
    }

//    //ffmpeg doesn't need to be written into execute
//    //clip out audio starting from second 2 take 4 seconds
//    int rc = await _flutterFfmpeg.execute("-ss 2 -t 4 -i ${file.path} $path");
//    if (rc == -1) {
//      print("An error occured while executing ffmpeg command");
//    } else {
//      print("FFmpeg process exited successfully with rc $rc");
//    }
//    editedAudioFile = File(path);

    //todo fill newBytes so it corresponds to a wav file that only contains the audio from start to end
    //Uint8List is a subtype of List<int> (more efficient)
//    Uint8List fileContentAsBytes = await file.readAsBytes();
//    print("file = $fileContentAsBytes");
//
//    var waveBuilder = WaveBuilder();
//
//    waveBuilder.appendFileContents(fileContentAsBytes);
//    var silenceType = WaveBuilderSilenceType.BeginningOfLastSample;
//    waveBuilder.appendSilence(1000, silenceType);
//    waveBuilder.appendFileContents(fileContentAsBytes);
//    List<int> newBytes = waveBuilder.fileBytes;
//    await newFile.writeAsBytes(newBytes);
//    editedAudioFile = newFile;
  }

//  createAudioFileFromScratch({@required int lengthInSec}) async {
//    var generator = WaveGenerator(
//        /* sample rate */ 44100,
//        BitDepth.Depth8bit);
//
//    var note = Note(
//        /* frequency */ 220,
//        /* msDuration */ 3000,
//        /* waveform */ Waveform.Triangle,
//        /* volume */ 0.5);
//
//    var file = new File('output.wav');
//
//    List<int> bytes = List<int>();
//    await for (int byte in generator.generate(note)) {
//      bytes.add(byte);
//    }
//
//    file.writeAsBytes(bytes, mode: FileMode.append);
//  }
}

class WaveCreator {
  static const int BITS_PER_SAMPLE = 16;
  static const int SAMPLE_RATE = 44100;
  static const int NUM_CHANNELS = 1;
  static const int BYTE_SIZE = 8;

  final Utf8Encoder _utf8encoder = Utf8Encoder();

  Future<File> createAudioFileChunkFromFile(
      {@required File file,
      @required int startInSec,
      @required int endInSec,
      @required String path}) async {
    int lengthOfAudio = endInSec - startInSec;

    List<int> outputBytes = [];
    outputBytes.addAll(_utf8encoder.convert('RIFF'));
    outputBytes.addAll(ByteUtils.numberAsByteList(0, 4, bigEndian: false));
    outputBytes.addAll(_utf8encoder.convert('WAVE'));

    File cutFile = File(path);
    await cutFile.writeAsBytes(outputBytes);

    return File(path);
  }
}

class ByteUtils {
  static List<int> numberAsByteList(int input, numBytes, {bigEndian = true}) {
    var output = <int>[], curByte = input;
    for (var i = 0; i < numBytes; ++i) {
      output.insert(bigEndian ? 0 : output.length, curByte & 255);
      curByte >>= 8;
    }
    return output;
  }

  static int findByteSequenceInList(List<int> sequence, List<int> list) {
    for (var outer = 0; outer < list.length; ++outer) {
      var inner = 0;
      for (;
          inner < sequence.length &&
              inner + outer < list.length &&
              sequence[inner] == list[outer + inner];
          ++inner) {}
      if (inner == sequence.length) {
        return outer;
      }
    }
    return -1;
  }
}
