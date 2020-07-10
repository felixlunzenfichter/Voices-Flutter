import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/screens/chat_screen/control_panel.dart';
import 'package:voices/screens/chat_screen/messages.dart';

enum Interface { Recording, Listening, Texting }

class ChatScreen extends StatelessWidget {
  final String chatId;
  final User otherUser;

  ChatScreen({
    @required this.chatId,
    @required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GlobalChatScreenInfo>(
      create: (_) => GlobalChatScreenInfo(
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
                child: MessagesStream(),
              ),
              ControlPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class GlobalChatScreenInfo extends ChangeNotifier {
  final String chatId;
  final User otherUser;

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

  GlobalChatScreenInfo({
    @required this.chatId,
    @required this.otherUser,
  });
}
