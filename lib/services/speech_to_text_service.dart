import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum RecordingStatus { ready, recording, paused }

class SpeechToTextService {
  final SpeechToText speech = SpeechToText();

  bool hasSpeech = false;
  bool _stressTest = false;
  double level = 0.0;
  int _stressLoops = 0;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];

  Future<void> initializeSpeechState(
      {@required Function errorListener,
      @required Function statusListener}) async {
    hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }
  }

//  record() async {
//    bool available = await speech.initialize(
//        onStatus: statusListener, onError: errorListener);
//    if (available) {
//      speech.listen(onResult: resultListener);
//    } else {
//      print("The user has denied the use of speech recognition.");
//    }
//    // some time later...
//    speech.stop();
//  }
}
