import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class FileConverterService {
  Future<File> createAudioFileChunkFromFile(
      {@required File file,
      @required int startInSec,
      @required int endInSec}) async {
    String path = file.parent.path + "/first_try_audio_cut.wav";
    File newFile = File(path);
    //todo fill newBytes so it corresponds to a wav file that only contains the audio from start to end

    //Uint8List is a "A fixed-length list of 8-bit unsigned integers"
    Uint8List fileContentAsBytes = await file.readAsBytes();
    print("file = $fileContentAsBytes");
//    List<int> newBytes;
//    newFile.writeAsBytes(newBytes);
    return newFile;
  }
}
