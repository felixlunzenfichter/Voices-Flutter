import 'dart:io';

import 'package:property_change_notifier/property_change_notifier.dart';

import 'package:voices/models/user.dart';
import 'package:voices/services/local_player_service.dart';
import 'package:voices/services/local_storage.dart';
import 'package:voices/services/recorder_service.dart';

enum Interface { Recording, Listening, Texting }

/// These are the Types of Notifications used by
/// the [PropertyChangeNotifier] [ConversationState].
enum MyNotification {
  InterfaceNotification,
  RecorderNotification,
  playerListeningSectionNotification,
  playerListeningSectionInitNotification,
  playerRecordingSectionNotification
}

/// State management for a particular conversation.
class ConversationState extends PropertyChangeNotifier<MyNotification> {
  final String chatId;
  final User otherUser;

  File listeningTo;

  void setListeningTo(File audioFile) {
    listeningTo = audioFile;
    notifyListeners(MyNotification.playerListeningSectionInitNotification);
  }

  /// --- NotifyListeners ---
  ///
  void notifyListenersInterface() {
    notifyListeners(MyNotification.InterfaceNotification);
    print('notified Interface.');
  }

  void notifyListenersRecorder() {
    notifyListeners(MyNotification.RecorderNotification);
    print('Recorder Notification.');
  }

  void notifyListenersPlayerListeningSection() {
    notifyListeners(MyNotification.playerListeningSectionNotification);
    print('PlayerListeningSection Notification.');
  }

  void notifyListenersPlayerRecordingSection() {
    notifyListeners(MyNotification.playerRecordingSectionNotification);
    print('PlayerRecordingSection Notification.');
  }

  /// --- Services ---
  ///
  RecorderService recorderService;
  LocalPlayerService playerListeningSection;
  LocalPlayerService playerRecordingSection;

  /// Used to access and store data locally.
  LocalStorageService localStorageService;

  /// Decide which controls to show right now.
  Interface showInterface = Interface.Recording;

  void showListeningSection() {
    showInterface = Interface.Listening;
    notifyListenersInterface();
  }

  void showRecordingSection() {
    showInterface = Interface.Recording;
    notifyListenersInterface();
  }

  void showTextInputSection() {
    showInterface = Interface.Texting;
    notifyListenersInterface();
  }

  ConversationState({this.chatId, this.otherUser}) {
    localStorageService = LocalStorageService(chatId: chatId);
    recorderService = RecorderService(notifyListeners: notifyListenersRecorder);
    playerRecordingSection = LocalPlayerService(
        notifyListenersCallback: notifyListenersPlayerRecordingSection);
    playerListeningSection = LocalPlayerService(
        notifyListenersCallback: notifyListenersPlayerListeningSection);

    /// Todo: Fetch currently listening and current recording from storage.
  }

  @override
  void dispose() {
    super.dispose();

    /// Todo: Save current recording and current listening in storage.
  }
}
