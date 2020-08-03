import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

import 'package:voices/models/user.dart';

import 'package:voices/screens/conversation_screen/control_panel.dart';
import 'package:voices/screens/conversation_screen/messages.dart';

import 'conversation_state.dart';

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
    return PropertyChangeProvider<ConversationState>(
      value: ConversationState(chatId: chatId, otherUser: otherUser),
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
              ConversationControlPanel(),
            ],
          ),
        ),
      ),
    );
  }
}
