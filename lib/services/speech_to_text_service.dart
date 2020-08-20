import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class SpeechToTextService extends ChangeNotifier {
  // Speech recognition object provided by the package.
  SpeechRecognition _speech;

  bool _isListening = false;
  bool _speechRecognitionAvailable = false;

  // Transcript since the las time we pressed start.
  String transcriptionCurrentRecordingSnippet = '';

  // Transcript of the whole voice message excluding since the last time we pressed start.
  String fullTranscription = '';

  // Currently German.
  Language selectedLang = languages.first;

  bool _isIOS = Platform.isIOS;

  SpeechToTextService() {
    if (_isIOS) {
      activateSpeechRecognizer();
    } else {
      fullTranscription = 'Speech to text is not available for Android yet.';
    }
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
    _speech.setRecognitionCompleteHandler((String done) {
      _isListening = false;
      saveTranscript();
    });
    _speech.activate().then((res) => _speechRecognitionAvailable = res);
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
    if (_isIOS) {
      _speechRecognitionAvailable && !_isListening
          ? _listen()
          : print(
              'Available: $_speechRecognitionAvailable. Is listening: $_isListening');
    }
  }

  _listen() {
    _speech
        .listen(locale: selectedLang.code)
        .then((result) => print('_MyAppState.start => result $result'));
  }

  // Stop recording and return text.
  Future<String> stop() async {
    String result;
    if (_isIOS) {
      await _speech.stop();
      saveTranscript();
      result = fullTranscription;
      fullTranscription = '';

      // Reset in case of error.
    } else {
      result = "Speech to text is not available for Android yet.";
    }
    return Future.value(result);
  }

  // Pause recording.
  void pause() async {
    if (_isIOS) {
      _isListening
          ? await _speech.stop()
          : print('Did not pause because is listening: $_isListening');
    }
  }

  void selectLangHandler(Language lang) {
    selectedLang = lang;
  }
}

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

const languages = const [
  const Language('Deutsch', 'de_DE'),
  const Language('Francais', 'fr_FR'),
  const Language('Español', 'es_ES'),
  const Language('English', 'en_US'),
  const Language('Russian', 'ru_RU'),
  const Language('Italiano', 'it_IT'),
];
