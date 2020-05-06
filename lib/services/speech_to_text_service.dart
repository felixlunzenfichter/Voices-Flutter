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
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);

    _speechRecognitionAvailable = await _speech.activate();
  }

  SpeechToTextService() {
    activateSpeechRecognizer();
  }

  // Start new Recording or pick up where we left off.
  void start() async {
    var result = _speech.listen(locale: selectedLang.code);
    print('_MyAppState.start => result $result');
    fullTranscription =
        fullTranscription + " " + transciptionCurrentRecoringSnippet;
    transciptionCurrentRecoringSnippet = '';
    notifyListeners();
    // todo: notify needed? Because state of _speech changed.
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

  void onSpeechAvailability(bool result) async {
    _speechRecognitionAvailable = result;
  }

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    selectedLang = languages.firstWhere((l) => l.code == locale);
  }

  void onRecognitionStarted() => _isListening = true;

  void onRecognitionResult(String text) {
    transciptionCurrentRecoringSnippet = text;
    notifyListeners();
  }

  void onRecognitionComplete() {
    _isListening = false;
  }

  void setLanguage() {}
}
