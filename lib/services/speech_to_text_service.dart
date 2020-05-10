import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter/material.dart';

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

const languages = const [
  const Language('Español', 'es_ES'),
  const Language('Francais', 'fr_FR'),
  const Language('English', 'en_US'),
  const Language('Pусский', 'ru_RU'),
  const Language('Italiano', 'it_IT'),
];

class SpeechToTextService extends ChangeNotifier {
  SpeechRecognition _speech;

  //todo use those
  bool _speechRecognitionAvailable = false;
  int i = 0;

  // Set to true when we are currently recording.
  bool _isListening = false;

  // Stopping the recorder can take time. Therefore we use this boolean
  // to postpone starting the recorder upon completing the stop.
  bool _shouldPlayOnComplete = false;

  String transciptionCurrentRecoringSnippet = '';
  String fullTranscription = '';

  //String _currentLocale = 'en_US';
  Language selectedLang = languages.first;

  void activateSpeechRecognizer() async {
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler((bool result) async {
      _speechRecognitionAvailable = result;
    });
    _speech.setCurrentLocaleHandler((String locale) {
      selectedLang = languages.firstWhere((l) => l.code == locale);
    });
    _speech.setRecognitionStartedHandler(() => {});
    _speech.setRecognitionResultHandler((String text) {
      transciptionCurrentRecoringSnippet = text;
      notifyListeners();
    });
    _speech.setRecognitionCompleteHandler(() async {
      if (_shouldPlayOnComplete) {
        // Don't Play upon next completion.
        _shouldPlayOnComplete = false;

        // Save transcript.
        fullTranscription =
        "$fullTranscription  $transciptionCurrentRecoringSnippet";
        transciptionCurrentRecoringSnippet = '';

        // Start listening.
        _speech.listen(locale: selectedLang.code);
      } else {
        // We are done listening.
        _isListening = false;

//        _speech.cancel();

        // Save transcript.
        fullTranscription =
        "$fullTranscription  $transciptionCurrentRecoringSnippet";
        transciptionCurrentRecoringSnippet = '';
      }
    });

    _speechRecognitionAvailable = await _speech.activate();
  }

  SpeechToTextService() {
    activateSpeechRecognizer();
  }

  // Start new Recording or pick up where we left off.
  void start() async {
    if (!_isListening) {
      // Start listening.
      _isListening = true;
      i += 1;
      print("start $i");
      _speech.listen(locale: selectedLang.code);
    } else {
      // Postpone start listening to onComplete.
      _shouldPlayOnComplete = true;
    }
  }

  // Stop recording
  void stop() async {
    await _speech.stop();
    fullTranscription = '';
    transciptionCurrentRecoringSnippet = '';
  }

  // Pause recording.
  void pause() async {
    await _speech.stop();
  }

  void setLanguage() {}
}
