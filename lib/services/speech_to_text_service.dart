import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter/material.dart';



class SpeechToTextService extends ChangeNotifier {

  // Speech recognition object provided by packet.
  SpeechRecognition _speech;


  int unresolvedStartClicks = 0;
  int pausesToSkip = 0;

  // Set to true when we are currently recording.
  bool _isListening = false;

  // Stopping the recorder can take time. Therefore we use this boolean
  // to postpone starting the recorder upon completing the stop.
  bool _shouldPlayOnComplete = false;

  // Transcript since the las time we pressed start.
  String transciptionCurrentRecoringSnippet = '';

  // Transcript of the whole voice message.
  String fullTranscription = '';

  //String _currentLocale = 'en_US';
  Language selectedLang = languages.first;

  SpeechToTextService() {
    activateSpeechRecognizer();
  }


  void activateSpeechRecognizer() async {
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler((bool result) async {});
    _speech.setCurrentLocaleHandler((String locale) {
      selectedLang = languages.firstWhere((l) => l.code == locale);
    });
    _speech.setRecognitionStartedHandler(() => {});
    _speech.setRecognitionResultHandler((String text) {
      transciptionCurrentRecoringSnippet = text;
      notifyListeners();
    });

    _speech.setRecognitionCompleteHandler(() async {
      unresolvedStartClicks--;

      // This case distinction takes care of potential pending start calls.
      if (_shouldPlayOnComplete) {
        // Don't Play upon next completion.
        _shouldPlayOnComplete = false;

        // Save transcript.
        saveTranscipt();

        // Start listening.
        _speech.listen(locale: selectedLang.code);
      } else {
        // We are done listening.
        _isListening = false;

        // Save transcript.
        saveTranscipt();
      }
    });
    await _speech.activate();
  }


  // Save transcript.
  saveTranscipt() {
    fullTranscription =
    "$fullTranscription$transciptionCurrentRecoringSnippet\n";
    transciptionCurrentRecoringSnippet = '';
  }

  // Start new Recording or pick up where we left off.
  void start() async {
    if (unresolvedStartClicks >= 2) {
      pausesToSkip++;
    } else {
      unresolvedStartClicks++;
      if (!_isListening) {
        // Start listening.
        _isListening = true;

        _speech.listen(locale: selectedLang.code);
      } else {
        // Postpone start listening to onComplete.
        _shouldPlayOnComplete = true;
      }
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
    if (pausesToSkip > 0) {
      pausesToSkip--;
    } else {
      await _speech.stop();
    }
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