import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class FileConverterService {
  final FlutterFFmpeg _flutterFfmpeg = new FlutterFFmpeg();

  Future<File> createAudioFileChunkFromFile(
      {@required File file,
      @required Duration startTime,
      @required Duration endTime,
      @required String chunkFilename}) async {
    assert(endTime > startTime);
    assert(file != null);

    String path = file.parent.path + "/$chunkFilename.wav";
    File newFile = File(path);
    if (await newFile.exists()) {
      await newFile.delete();
    }

    //clip out audio starting from startTime to endTime
    Duration lengthOfChunk = endTime - startTime;
    String start = _convertDurationToExpectedFormat(duration: startTime);
    String length = _convertDurationToExpectedFormat(duration: lengthOfChunk);

    if (await _flutterFfmpeg
            .execute("-ss $start -t $length -i ${file.path} $path") ==
        -1) {
      print("An error occured while executing ffmpeg trim command");
    } else {
      print("ffmpeg trimming exited successfully");
    }
    return File(path);
  }

  //this method returns the concatenated file once the ffmpeg command is done executing
  Future<File> appendChunkToFileAndSave(
      {@required File file,
      @required File chunk,
      @required String newFilename}) async {
    assert(file != null);
    assert(chunk != null);
    assert(newFilename != null);

    String parentDirectoryPath = file.parent.path;

    //we need to create a text file that contains the paths of the files we want to concatenate
    String textFileContent = "file '${file.path}'\nfile '${chunk.path}'";
    String textFilePath = parentDirectoryPath + "/filesToConcatenate.txt";
    File textFile =
        await File(textFilePath).writeAsString(textFileContent, flush: true);

    String newFilePath = parentDirectoryPath + "/$newFilename.wav";

    if (await _flutterFfmpeg.execute(
            "-f concat -safe 0 -i ${textFile.path} -c copy $newFilePath") ==
        -1) {
      print("An error occured while executing ffmpeg concat command");
    } else {
      print("ffmpeg concatenating exited successfully");
    }
    return File(newFilePath);
  }

  String _convertDurationToExpectedFormat({@required Duration duration}) {
    return "${_twoDigits(duration.inHours)}:${_twoDigits(duration.inMinutes)}:${_twoDigits(duration.inSeconds)}.${_fourDigits(duration.inMilliseconds)}";
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String _fourDigits(int n) {
    if (n < 10) {
      return "000$n";
    } else if (n < 100) {
      return "00$n";
    } else if (n < 1000) {
      return "0$n";
    } else if (n > 1000) {
      return "$n";
    }
    return n.toString();
  }
}
