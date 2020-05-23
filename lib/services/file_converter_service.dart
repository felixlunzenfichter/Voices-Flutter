import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

class FileConverterService {
  final FlutterFFmpeg _flutterFfmpeg = new FlutterFFmpeg();

  /// The files to be concatenated should have the same file extension as the one in newFilename
  Future<File> concatenate(
      {@required File file1,
      @required File file2,
      @required String newFilename}) async {
    assert(file1 != null);
    assert(file2 != null);
    assert(newFilename != null);

    String parentDirectoryPath = file1.parent.path;

    /// The ffmpeg command needs a text file which specifies all the file paths of the files it needs to concatenate
    String textFilePath = parentDirectoryPath + "/filesToConcatenate.txt";
    File textFile = File(textFilePath);
    String textFileContent = "file '${file1.path}'\nfile '${file2.path}'";

    /// This overwrites the contents of the file if it already exist
    await textFile.writeAsString(textFileContent, flush: true);

    String newFilePath = parentDirectoryPath + "/" + newFilename;

    /// Todo understand every part of this command (-safe 0 and -c copy)
    /// -c copy omits the decoding and encoding step so its faster but can probably only be used if the input and output file formats are all the same
    /// -y is necessary to overwrite the output file
    if (await _flutterFfmpeg.execute(
            "-f concat -y -safe 0 -i ${textFile.path} -c copy $newFilePath") ==
        -1) {
      print("An error occured while executing ffmpeg concat command");
    } else {
      print("ffmpeg concatenating exited successfully");
    }
    return File(newFilePath);
  }

  /// This function overwrites the file currently saved at toPath
  /// The file paths involved already contain the file extensions
  convertFileFromRecordingToListeningFormatAndSaveUnter(
      {@required File file, @required String toPath}) async {
    if (await _flutterFfmpeg.execute("-i ${file.path} -y $toPath") == -1) {
      print(
          "An error occured while executing ffmpeg command to convert from recording to listening audio format");
    } else {
      print("ffmpeg converting exited successfully");
    }
  }

  copyFileTo({@required File file, @required String toPath}) async {
    /// This overwrites the file at toPath if it exists
    await file.copy(toPath);
  }

  deleteFileAt({@required String path}) async {
    await File(path).delete();
  }

  Future<File> createAudioFileChunkFromFile(
      {@required File file,
      @required Duration startTime,
      @required Duration endTime,
      @required String chunkFilename}) async {
    assert(endTime > startTime);
    assert(file != null);

    String path = file.parent.path + "/$chunkFilename.aac";
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
