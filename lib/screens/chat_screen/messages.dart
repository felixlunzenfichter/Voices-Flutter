import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/message.dart';
import 'package:voices/screens/chat_screen/widgets.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';

import 'chat_screen.dart';

class MessagesStream extends StatefulWidget {
  @override
  _MessagesStreamState createState() => _MessagesStreamState();
}

class _MessagesStreamState extends State<MessagesStream> {
  Stream<List<Message>> messagesStream;

  @override
  void initState() {
    super.initState();
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    GlobalChatScreenInfo screenInfo =
        Provider.of<GlobalChatScreenInfo>(context, listen: false);
    messagesStream =
        cloudFirestoreService.getMessageStream(chatId: screenInfo.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none) {
          return CupertinoActivityIndicator();
        }

        if (snapshot.hasError) {
          return Container(
            color: Colors.red,
            child: Text(snapshot.error.toString()),
          );
        }

        final List<Message> messages = snapshot.data;

        if (messages == null || messages.isEmpty) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Text(
                "There are no messages yet",
              ),
            ),
          );
        }
        return ListOfMessages(
          messages: messages,
        );
      },
    );
  }
}

class ListOfMessages extends StatefulWidget {
  final List<Message> messages;

  ListOfMessages({@required this.messages});

  @override
  _ListOfMessagesState createState() => _ListOfMessagesState();
}

class _ListOfMessagesState extends State<ListOfMessages>
    with SingleTickerProviderStateMixin {
  List<Message> _messages;
  final _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
  }

  @override
  void didUpdateWidget(ListOfMessages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages.length < widget.messages.length) {
      for (int i = 0;
          i < widget.messages.length - oldWidget.messages.length;
          i++) {
        _insertMessageAtIndex(message: widget.messages[i], index: i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<LoggedInUserService>(context, listen: false);

    return AnimatedList(
      key: _listKey,
      initialItemCount: _messages.length,
      itemBuilder: (context, index, animation) {
        Message message = _messages[index];
        return MessageRow(
          message: message,
          isMe: authService.loggedInUser.uid == message.senderUid,
        );
      },
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
    );
  }

  _insertMessageAtIndex({@required Message message, @required int index}) {
    _messages.insert(index, message);
    _listKey.currentState.insertItem(index);
  }
}
