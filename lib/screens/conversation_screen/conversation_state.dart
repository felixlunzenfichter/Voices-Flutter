import 'dart:io';

import 'package:flutter/material.dart';
import 'package:voices/models/user.dart';

enum Interface { Recording, Listening, Texting }

/// These are the Types of Notifications used by
/// the [PropertyChangeNotifier] [ConversationState].
/// Todo: Remove this.

/// State management for a particular conversation.
class ConversationState extends ChangeNotifier {
  final String chatId;
  final User otherUser;

  File listeningTo;

  void setListeningTo(File audioFile) {
    listeningTo = audioFile;
    notifyListeners();
  }

  /// Decide which controls to show right now.
  Interface showInterface = Interface.Recording;

  void showListeningSection() {
    showInterface = Interface.Listening;
    notifyListeners();
  }

  void showRecordingSection() {
    showInterface = Interface.Recording;
    notifyListeners();
  }

  void showTextInputSection() {
    showInterface = Interface.Texting;
    notifyListeners();
  }

  ConversationState({this.chatId, this.otherUser}) {
    /// Todo: Fetch currently listening and current recording from storage.
  }

  @override
  void dispose() {
    super.dispose();

    /// Todo: Save current recording and current listening in storage.
  }
}
