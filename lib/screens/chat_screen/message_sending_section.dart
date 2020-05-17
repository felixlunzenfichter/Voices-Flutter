import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/screens/chat_screen/chat_screen.dart';
import 'package:voices/screens/chat_screen/widgets.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';

class MessageSendingSection extends StatefulWidget {
  @override
  _MessageSendingSectionState createState() => _MessageSendingSectionState();
}

class _MessageSendingSectionState extends State<MessageSendingSection> {
  final TextEditingController _messageTextController = TextEditingController();
  String _messageText = "";

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final screenInfo =
        Provider.of<GlobalChatScreenInfo>(context, listen: false);

    return Column(
      children: <Widget>[
        RecordingAndPlayingInfo(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: SendTextField(
                    controller: _messageTextController,
                    onTextChanged: _onTextChanged)),
            if (_messageText != "")
              SendTextButton(
                onPress: () async {
                  // prevent to send the previously typed message with an empty text field
                  //Implement send functionality.
                  TextMessage message = TextMessage(
                      senderUid: authService.loggedInUser.uid,
                      text: _messageText);
                  final cloudFirestoreService =
                      Provider.of<CloudFirestoreService>(context,
                          listen: false);
                  cloudFirestoreService.addTextMessage(
                      chatId: screenInfo.chatId, textMessage: message);
                  //clear text field
                  _messageTextController.text = "";
                },
              )
            else
              RecorderControls(),
          ],
        ),
      ],
    );
  }

  _onTextChanged(String newText) {
    setState(() {
      _messageText = newText;
    });
  }
}
