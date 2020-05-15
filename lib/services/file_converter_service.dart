//import 'dart:io';
//import 'package:flutter/foundation.dart';
//import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class FileConverterService {
//  final FlutterFFmpeg _flutterFfmpeg = new FlutterFFmpeg();
//
//  Future<File> createAudioFileChunkFromFile(
//      {@required File file,
//      @required Duration startTime,
//      @required Duration endTime,
//      @required String chunkFilename}) async {
//    assert(endTime > startTime);
//    assert(file != null);
//
//    String path = file.parent.path + "/$chunkFilename.aac";
//    File newFile = File(path);
//    if (await newFile.exists()) {
//      await newFile.delete();
//    }
//
//    //clip out audio starting from startTime to endTime
//    Duration lengthOfChunk = endTime - startTime;
//    String start = _convertDurationToExpectedFormat(duration: startTime);
//    String length = _convertDurationToExpectedFormat(duration: lengthOfChunk);
//
//    if (await _flutterFfmpeg
//            .execute("-ss $start -t $length -i ${file.path} $path") ==
//        -1) {
//      print("An error occured while executing ffmpeg trim command");
//    } else {
//      print("ffmpeg trimming exited successfully");
//    }
//    return File(path);
//  }
//
//  String _convertDurationToExpectedFormat({@required Duration duration}) {
//    return "${_twoDigits(duration.inHours)}:${_twoDigits(duration.inMinutes)}:${_twoDigits(duration.inSeconds)}.${_fourDigits(duration.inMilliseconds)}";
//  }
//
//  String _twoDigits(int n) {
//    if (n >= 10) return "$n";
//    return "0$n";
//  }
//
//  String _fourDigits(int n) {
//    if (n < 10) {
//      return "000$n";
//    } else if (n < 100) {
//      return "00$n";
//    } else if (n < 1000) {
//      return "0$n";
//    } else if (n > 1000) {
//      return "$n";
//    }
//    return n.toString();
//  }
}
