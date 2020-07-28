import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/screens/conversation_screen/control_panel.dart';
import 'package:voices/screens/conversation_screen/messages.dart';
import 'package:voices/services/local_storage.dart';
import 'package:voices/services/recorder_service.dart';

enum Interface { Recording, Listening, Texting }

class ConversationScreen extends StatelessWidget {
  final String chatId;
  final User otherUser;

  ConversationScreen({
    @required this.chatId,
    @required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    /// State management for this chat window.
    return ChangeNotifierProvider<ConversationState>(
      create: (_) => ConversationState(
        chatId: chatId,
        otherUser: otherUser,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(otherUser.username),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: MessagesStream(
                  chatId: chatId,
                ),
              ),
              ControlPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

/// State management for a particular conversation.
class ConversationState extends ChangeNotifier {
  final String chatId;
  final User otherUser;

  File listeningTo;
  File currentRecording;

  setListeningTo({File audioFile}) {
    listeningTo = audioFile;
    notifyListeners();
  }

  /// Used to store currentRecording and listeningTo when exiting the conversation.
  LocalStorageService localStorageService;

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
    localStorageService = LocalStorageService(chatId: chatId);

    /// Todo: Fetch currently listening and current recording from storage.
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    print('Dispose chat window.');

    /// Todo: Save current recording and current listening in storage.
//    Recording recording = recorderService.recording;
//    if (recording != null) {
//      localStorageService.saveCurrentRecording(recording: recording);
//    }
  }
}
