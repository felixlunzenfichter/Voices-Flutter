import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class AudioService {
  StreamSubscription<List<int>> _micStreamSubscription;
  bool _areWeOnIOS = false;
  static final int samplingFrequency =
      44100; //this is the industry standard for audio files
  static final int chunkTimeInSec = 2;
  static final int _samplesPerChunk = chunkTimeInSec * samplingFrequency;

  initialize({@required bool areWeOnIOS}) async {
    _areWeOnIOS = areWeOnIOS;
  }

  startRecordingChunks({@required Function whatToDoWithChunk}) {
    Stream<List<int>> microphoneStream = _getMicrophoneStream();
    _micStreamSubscription = microphoneStream.listen(
      (List<int> micData) {
        ///this is called whenever there is a new int in the list
        ///here we want to check if a certain amount of time has passed
        ///or a certain amount of ints is in the list and then merge them into a file
        //todo create audiofile
        print("micData arrived with length = ${micData.length}");
        var audioFileChunk = new File('output.wav');
        audioFileChunk.writeAsBytes(micData, mode: FileMode.append);
        whatToDoWithChunk(audioFileChunk);
      },
      onError: (error) {
        print(
            "couldn't get correct micData because of error: ${error.toString()}");
      },
      onDone: () {
        print("stream is finished sending data");
      },
      cancelOnError: true,
    ); //cancelOnError is true by default and should be set to false if we want to keep the subscription going even after an error
  }

  pauseRecordingChunks() {
    _micStreamSubscription.pause();
  }

  resumeRecordingChunks() {
    _micStreamSubscription.resume();
  }

  stopRecordingChunks() {
    _micStreamSubscription.cancel();
  }

  Stream<List<int>> _getMicrophoneStream() {
    return Stream.empty();
  }
}
