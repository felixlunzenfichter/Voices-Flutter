import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/screens/chat_screen/message_sending_section.dart';
import 'package:voices/screens/chat_screen/messages.dart';


class ChatScreen extends StatelessWidget {
  final String chatId;
  final User otherUser;

  ChatScreen({
    @required this.chatId,
    @required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalChatScreenInfo>(
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
              MessageSendingSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class GlobalChatScreenInfo {
  final String chatId;
  final User otherUser;

  GlobalChatScreenInfo({
    @required this.chatId,
    @required this.otherUser,
  });
}
