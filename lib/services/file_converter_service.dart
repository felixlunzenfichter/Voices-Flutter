import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:wave_generator/wave_generator.dart';

class FileConverterService {
  File editedAudioFile;

  createAudioFileChunkFromFile(
      {@required File file,
      @required int startInSec,
      @required int endInSec}) async {
    String path = file.parent.path + "/first_try_audio_cut.wav";
    File newFile = File(path);
    if (await newFile.exists()) {
      await newFile.delete();
    }
    newFile = File(path);

    //todo fill newBytes so it corresponds to a wav file that only contains the audio from start to end
    //Uint8List is a subtype of List<int> (more efficient)
    Uint8List fileContentAsBytes = await file.readAsBytes();
    print("file = $fileContentAsBytes");

    var waveBuilder = WaveBuilder();

    waveBuilder.appendFileContents(fileContentAsBytes);
    var silenceType = WaveBuilderSilenceType.BeginningOfLastSample;
    waveBuilder.appendSilence(1000, silenceType);
    waveBuilder.appendFileContents(fileContentAsBytes);
    List<int> newBytes = waveBuilder.fileBytes;
    await newFile.writeAsBytes(newBytes);
    editedAudioFile = newFile;
  }

  createAudioFileFromScratch({@required int lengthInSec}) async {
    var generator = WaveGenerator(
        /* sample rate */ 44100,
        BitDepth.Depth8bit);

    var note = Note(
        /* frequency */ 220,
        /* msDuration */ 3000,
        /* waveform */ Waveform.Triangle,
        /* volume */ 0.5);

    var file = new File('output.wav');

    List<int> bytes = List<int>();
    await for (int byte in generator.generate(note)) {
      bytes.add(byte);
    }

    file.writeAsBytes(bytes, mode: FileMode.append);
  }
}

/// This flag is used when appending silence.
/// Determines whether or not to start the silence timer at the beginning or end of the
/// last sample appended to this file.
enum WaveBuilderSilenceType { BeginningOfLastSample, EndOfLastSample }

/// Build a wave file.
class WaveBuilder {
  static const int RIFF_CHUNK_SIZE_INDEX = 4;
  static const int SUB_CHUNK_SIZE = 16;
  static const int AUDIO_FORMAT = 1;
  static const int BYTE_SIZE = 8;

  int _lastSampleSize;

  /// Finalizes the header sizes and returns bytes
  List<int> get fileBytes {
    _finalize();
    return _outputBytes;
  }

  List<int> _outputBytes;
  final Utf8Encoder _utf8encoder = Utf8Encoder();

  int _dataChunkSizeIndex;

  int _bitRate;
  int _frequency;
  int _numChannels;

  /// Construct a wave builder.
  /// Supply audio file properties.
  WaveBuilder({int bitRate = 16, int frequency = 44100, bool stereo = true}) {
    _outputBytes = <int>[];
    _bitRate = bitRate;
    _frequency = frequency;
    _numChannels = stereo ? 2 : 1;
    _initializeWave();
  }

  void _initializeWave() {
    _outputBytes.addAll(_utf8encoder.convert('RIFF'));
    _outputBytes.addAll(ByteUtils.numberAsByteList(0, 4, bigEndian: false));
    _outputBytes.addAll(_utf8encoder.convert('WAVE'));

    _createFormatChunk();
    _writeDataChunkHeader();
  }

  void _createFormatChunk() {
    var byteRate = _frequency * _numChannels * _bitRate ~/ BYTE_SIZE,
        blockAlign = _numChannels * _bitRate ~/ 8,
        bitsPerSample = _bitRate;
    _outputBytes.addAll(_utf8encoder.convert('fmt '));
    _outputBytes.addAll(
        ByteUtils.numberAsByteList(SUB_CHUNK_SIZE, 4, bigEndian: false));
    _outputBytes
        .addAll(ByteUtils.numberAsByteList(AUDIO_FORMAT, 2, bigEndian: false));
    _outputBytes
        .addAll(ByteUtils.numberAsByteList(_numChannels, 2, bigEndian: false));
    _outputBytes
        .addAll(ByteUtils.numberAsByteList(_frequency, 4, bigEndian: false));
    _outputBytes
        .addAll(ByteUtils.numberAsByteList(byteRate, 4, bigEndian: false));
    _outputBytes
        .addAll(ByteUtils.numberAsByteList(blockAlign, 2, bigEndian: false));
    _outputBytes
        .addAll(ByteUtils.numberAsByteList(bitsPerSample, 2, bigEndian: false));
  }

  void _writeDataChunkHeader() {
    _outputBytes.addAll(_utf8encoder.convert('data'));
    _dataChunkSizeIndex = _outputBytes.length;
    _outputBytes.addAll(ByteUtils.numberAsByteList(0, 4, bigEndian: false));
  }

  /// Find data chunk content after <data|size> in [fileContents]
  List<int> getDataChunk(List<int> fileContents) {
    final dataIdSequence = _utf8encoder.convert('data');
    final dataIdIndex =
        ByteUtils.findByteSequenceInList(dataIdSequence, fileContents);
    var dataStartIndex = 0;

    if (dataIdIndex != -1) {
      // Add 4 for data size
      dataStartIndex = dataIdIndex + dataIdSequence.length + 4;
    }
    return fileContents.sublist(dataStartIndex);
  }

  /// Append [fileContents] read as bytes to our wave file.
  /// If [findDataChunk] is true, searches first to find the file's data chunk.
  /// It's recommended to call getDataChunk on the file contents you want to append first,
  /// to prevent repeating everytime you add the same file.
  void appendFileContents(List<int> fileContents, {bool findDataChunk = true}) {
    var dataChunk = findDataChunk ? getDataChunk(fileContents) : fileContents;
    _lastSampleSize = dataChunk.length;
    _outputBytes.addAll(dataChunk);
  }

  /// Append [msLength] milliseconds of silence to our wave file.
  /// [silenceType] determines whether we start the counter for silence
  /// from the beginning of the last sample or the end.
  void appendSilence(int msLength, WaveBuilderSilenceType silenceType) {
    var byteRate = _frequency * _bitRate ~/ 8;
    var length = (msLength * byteRate ~/ 1000) * _numChannels;
    if (silenceType == WaveBuilderSilenceType.BeginningOfLastSample) {
      if (length > _lastSampleSize) {
        length -= _lastSampleSize;
      } else {
        _outputBytes.removeRange(_outputBytes.length - _lastSampleSize + length,
            _outputBytes.length);
        length = 0;
      }
    }

    _outputBytes.addAll(List<int>.filled(length, 0));
  }

  void _updateRiffChunkSize() {
    _outputBytes.replaceRange(
        RIFF_CHUNK_SIZE_INDEX,
        RIFF_CHUNK_SIZE_INDEX + 4,
        ByteUtils.numberAsByteList(
            _outputBytes.length - (RIFF_CHUNK_SIZE_INDEX + 4), 4,
            bigEndian: false));
  }

  void _updateDataChunkSize() {
    _outputBytes.replaceRange(
        _dataChunkSizeIndex,
        _dataChunkSizeIndex + 4,
        ByteUtils.numberAsByteList(
            _outputBytes.length - (_dataChunkSizeIndex + 4), 4,
            bigEndian: false));
  }

  void _finalize() {
    _updateRiffChunkSize();
    _updateDataChunkSize();
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
