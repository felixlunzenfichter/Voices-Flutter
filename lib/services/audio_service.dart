import 'dart:async';
import 'dart:io';
import 'package:audio_streams/audio_streams.dart';
import 'package:mic_stream/mic_stream.dart'; //works only for android
import 'package:flutter/cupertino.dart'; //works only for iOS

class AudioService {
  AudioController _iOSAudioController;
  StreamSubscription<List<int>> _micStreamSubscription;
  bool _areWeOnIOS = false;
  static final int samplingFrequency =
      44100; //this is the industry standard for audio files
  static final int chunkTimeInSec = 2;
  static final int _samplesPerChunk = chunkTimeInSec * samplingFrequency;

  initialize({@required bool areWeOnIOS}) async {
    _areWeOnIOS = areWeOnIOS;
    if (_areWeOnIOS) {
      _iOSAudioController =
          AudioController(CommonFormat.Int16, samplingFrequency, 1, true);
      await _iOSAudioController.intialize();
    }
  }

  startRecording() {}

  startRecordingChunks({@required Function whatToDoWithChunk}) {
    Stream<List<int>> microphoneStream = _getMicrophoneStream();
    int currentNumberOfChunks = 0;
    _micStreamSubscription = microphoneStream.listen((List<int> micData) {
      ///this is called whenever there is a new int in the list
      ///here we want to check if a certain amount of time has passed
      ///or a certain amount of ints is in the list and then merge them into a file
      //todo create audiofile
      print("micData arrived with length = ${micData.length}");
//      var audioFileChunk = new File('output.wav');
//      audioFileChunk.writeAsBytes(micData, mode: FileMode.append);
//      whatToDoWithChunk(audioFileChunk);
    });
  }

  stopRecordingChunks() {
    _micStreamSubscription.cancel();
  }

  pauseRecording() {}

  finishRecording() {}

  Stream<List<int>> _getMicrophoneStream() {
    if (_areWeOnIOS) {
      return _iOSAudioController.startAudioStream();
    } else {
      return microphone(
          sampleRate: samplingFrequency,
          audioFormat: AudioFormat.ENCODING_PCM_16BIT);
    }
  }
}
