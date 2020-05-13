import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter/material.dart';



class SpeechToTextService extends ChangeNotifier {

  // Speech recognition object provided by the package.
  SpeechRecognition _speech;

  bool _isListening = false;
  bool _speechRecognitionAvailable = false;

  // Transcript since the las time we pressed start.
  String transcriptionCurrentRecordingSnippet = '';

  // Transcript of the whole voice message excluding since the last time we pressed start.
  String fullTranscription = '';

  //String _currentLocale = 'en_US';
  Language selectedLang = languages.first;

  SpeechToTextService() {
    activateSpeechRecognizer();
  }

  void activateSpeechRecognizer() async {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler((bool result) {
      _speechRecognitionAvailable = result;
    });
    _speech.setCurrentLocaleHandler((String locale) {
      selectedLang = languages.firstWhere((l) => l.code == locale);
    });
    _speech.setRecognitionStartedHandler(() => _isListening = true);
    _speech.setRecognitionResultHandler((String text) {
      transcriptionCurrentRecordingSnippet = text;
      notifyListeners();
    });
    _speech.setRecognitionCompleteHandler(() {
      _isListening = false;
      saveTranscript();
    });
    _speech
        .activate()
        .then((res) => _speechRecognitionAvailable = res);
  }

  // Save transcript.
  saveTranscript() {
    fullTranscription =
    "$fullTranscription$transcriptionCurrentRecordingSnippet\n";
    transcriptionCurrentRecordingSnippet = '';
    notifyListeners();
  }

  // Start new Recording or pick up where we left off.
  void start() {
    _speechRecognitionAvailable && !_isListening ? _listen() : print(
        'Available: $_speechRecognitionAvailable. Is listening: $_isListening');
  }

  _listen() {
    _speech.listen(locale: selectedLang.code).then((result) =>
        print('_MyAppState.start => result $result'));
  }

  // Stop recording and return text.
  Future<String> stop() async {
    await _speech.stop();
    saveTranscript();
    String result = fullTranscription;
    fullTranscription = '';

    // Reset in case of error.
    activateSpeechRecognizer();
    return Future.value(result);
  }

  // Pause recording.
  void pause() async {
    _isListening ? await _speech.stop() : print(
        'Did not pause because is listening: $_isListening');
  }

  void setLanguage() {}
}

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

const languages = const [
  const Language('Francais', 'fr_FR'),
  const Language('Español', 'es_ES'),
  const Language('English', 'en_US'),
  const Language('Pусский', 'ru_RU'),
  const Language('Italiano', 'it_IT'),
];