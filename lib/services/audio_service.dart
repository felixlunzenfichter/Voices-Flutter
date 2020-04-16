import 'dart:async';
import 'package:audio_streams/audio_streams.dart';
import 'package:mic_stream/mic_stream.dart'; //works only for android
import 'package:flutter/cupertino.dart'; //works only for iOS

enum Platform { iOS, android }

class AudioService {
  AudioController iOSAudioController;

  askForPermission() {
    //todo ask for permission to use microphone
  }

  initialize({@required Platform platform}) async {
    if (platform == Platform.iOS) {
      iOSAudioController = AudioController(CommonFormat.Int16, 16000, 1, true);
      await iOSAudioController.intialize();
    }
  }

  startRecording() async {}

  pauseRecording() {}

  finishRecording() {}

  Stream<List<int>> _getMicrophoneStream({@required Platform platform}) {
    if (platform == Platform.android) {
      return microphone(
          sampleRate: 16000, audioFormat: AudioFormat.ENCODING_PCM_16BIT);
    } else {
      return iOSAudioController.startAudioStream();
    }
  }
}
