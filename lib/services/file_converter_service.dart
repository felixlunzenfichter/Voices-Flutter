import 'dart:io';
import 'package:flutter/foundation.dart';
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

    //clip out audio starting from second 2 take 2 seconds
    int rc = await _flutterFfmpeg.execute("-ss 2 -t 2 -i ${file.path} $path");
    if (rc == -1) {
      print("An error occured while executing ffmpeg command");
    } else {
      print("ffmpeg exited successfully");
    }
    editedAudioFile = File(path);
  }
}
