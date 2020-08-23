import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

import 'package:voices/models/user.dart';

import 'package:voices/screens/conversation_screen/control_panel.dart';
import 'package:voices/screens/conversation_screen/messages.dart';
import 'package:voices/services/local_player_service.dart';
import 'package:voices/services/local_storage.dart';
import 'package:voices/services/recorder_service.dart';

import 'conversation_state.dart';

enum PlayerServiceType { listening, recording }

/// 2 Wrappers to be able to provide different types in [MultiProvider].
class PlayerListeningSection extends ChangeNotifier {
  LocalPlayerService localPlayerService;

  PlayerListeningSection() {
    localPlayerService =
        LocalPlayerService(notifyListenersCallback: notifyListeners);
  }
}

class PlayerRecordingSection extends ChangeNotifier {
  LocalPlayerService localPlayerService;
  PlayerRecordingSection() {
    localPlayerService =
        LocalPlayerService(notifyListenersCallback: notifyListeners);
  }
}

class ConversationScreen extends StatelessWidget {
  final String chatId;
  final User otherUser;

  ConversationScreen({
    @required this.chatId,
    @required this.otherUser,
  });

  RecorderService recorderService = RecorderService();
  PlayerListeningSection playerListeningSection = PlayerListeningSection();
  PlayerRecordingSection playerRecordingSection = PlayerRecordingSection();

  /// Used to access and store data locally.
  LocalStorageService localStorageService;
  @override
  Widget build(BuildContext context) {
    /// State management for this chat window.
    return ChangeNotifierProvider<ConversationState>(
      create: (_) => ConversationState(chatId: chatId, otherUser: otherUser),
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
              MultiProvider(
                providers: [
                  ChangeNotifierProvider<RecorderService>(
                      create: (_) => recorderService),
                  ChangeNotifierProvider<PlayerListeningSection>(
                    create: (_) => playerListeningSection,
                  ),
                  ChangeNotifierProvider<PlayerRecordingSection>(
                    create: (_) => playerRecordingSection,
                  ),
                  ChangeNotifierProvider<LocalStorageService>(
                    create: (_) => LocalStorageService(chatId: chatId),
                  )
                ],
                child: ConversationControlPanel(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
