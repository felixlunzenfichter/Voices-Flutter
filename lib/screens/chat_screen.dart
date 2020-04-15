import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/message.dart';
import 'package:voices/models/user.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/shared%20widgets/profile_picture.dart';
import 'package:voices/shared%20widgets/time_stamp_text.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final User loggedInUser;
  final User otherUser;

  ChatScreen({
    @required this.chatId,
    @required
        this.loggedInUser, //is needed because this screen can't access it with provider
    @required this.otherUser,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream<List<Message>> messageStream;

  @override
  void initState() {
    super.initState();
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    messageStream =
        cloudFirestoreService.getMessageStream(chatId: widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalChatScreenInfo>(
      create: (_) => GlobalChatScreenInfo(
        chatId: widget.chatId,
        loggedInUser: widget.loggedInUser,
        otherUser: widget.otherUser,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.otherUser.username),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: MessagesStream(
                  messagesStream: messageStream,
                ),
              ),
              MessageSendingSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final messagesStream;

  MessagesStream({this.messagesStream});

  @override
  Widget build(BuildContext context) {
    GlobalChatScreenInfo screenInfo =
        Provider.of<GlobalChatScreenInfo>(context, listen: false);
    return StreamBuilder<List<Message>>(
      stream: messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none) {
          return CupertinoActivityIndicator();
        }

        final List<Message> messages = snapshot.data;

        if (messages == null) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Text(
                "There are no messages yet",
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            Message message = messages[index];
            return MessageRow(
              message: message,
              isMe: screenInfo.loggedInUser.uid == message.senderUid,
            );
          },
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
        );
      },
    );
  }
}

class MessageSendingSection extends StatefulWidget {
  @override
  _MessageSendingSectionState createState() => _MessageSendingSectionState();
}

class _MessageSendingSectionState extends State<MessageSendingSection> {
  final messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: CupertinoTextField(
              textCapitalization: TextCapitalization.sentences,
              autocorrect: false,
              maxLength: 200,
              expands: true,
              maxLines: null,
              minLines: null,
              placeholder: "Enter message",
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              controller: messageTextController,
            ),
          ),
        ),
        SendButton(
          onPress: () async {
            // prevent to send the previously typed message with an empty text field
            if (messageTextController.text != '') {
              //Implement send functionality.
              GlobalChatScreenInfo screenInfo =
                  Provider.of<GlobalChatScreenInfo>(context, listen: false);
              Message message = Message(
                  senderUid: screenInfo.loggedInUser.uid,
                  text: messageTextController.text);
              cloudFirestoreService.addMessage(
                  chatId: screenInfo.chatId, message: message);
              messageTextController.clear(); // Reset locally the sent message
            }
          },
        ),
      ],
    );
  }
}

class MessageRow extends StatelessWidget {
  MessageRow({this.message, this.isMe});

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
      child: Column(
        // a column with just one child because I haven't figure out out else to size the bubble to fit its contents instead of filling it
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          MessageBubble(
              isMe: isMe, text: message.text, timestamp: message.timestamp),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key key,
    @required this.isMe,
    @required this.text,
    @required this.timestamp,
  }) : super(key: key);

  final bool isMe;
  final String text;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: isMe
          ? BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15))
          : BorderRadius.only(
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15)),
      elevation: 0.0,
      color: isMe ? Colors.yellow : Colors.teal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            TimeStampText(timestamp: timestamp)
          ],
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final Function onPress;

  SendButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPress,
      child: Container(
        padding: EdgeInsets.all(9),
        decoration:
            ShapeDecoration(color: Colors.tealAccent, shape: CircleBorder()),
        child: Icon(
          Icons.send,
          color: Colors.brown,
          size: 22,
        ),
      ),
    );
  }
}

class GlobalChatScreenInfo {
  final String chatId;
  final User loggedInUser;
  final User otherUser;

  GlobalChatScreenInfo({
    @required this.chatId,
    @required this.loggedInUser,
    @required this.otherUser,
  });
}
