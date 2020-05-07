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
  bool _isListening = false;

  String transciptionCurrentRecoringSnippet = ' snip';
  String fullTranscription = 'nottin';

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
    _speech.setRecognitionStartedHandler(() => _isListening = true);
    _speech.setRecognitionResultHandler((String text) {
      transciptionCurrentRecoringSnippet = text;
      notifyListeners();
    });
    _speech.setRecognitionCompleteHandler(() {
      _isListening = false;
    });

    _speechRecognitionAvailable = await _speech.activate();
  }

  SpeechToTextService() {
    activateSpeechRecognizer();
  }

  // Start new Recording or pick up where we left off.
  void start() async {
    var result = _speech.listen(locale: selectedLang.code);
    fullTranscription =
        fullTranscription + " " + transciptionCurrentRecoringSnippet;
    transciptionCurrentRecoringSnippet = '';
  }

  // Stop recording
  void stop() async {
    _isListening = await _speech.cancel();
    fullTranscription = '';
    transciptionCurrentRecoringSnippet = '';
  }

  // Pause recording.
  void pause() async {
    _isListening = await _speech.stop();
  }

  void setLanguage() {}
}
