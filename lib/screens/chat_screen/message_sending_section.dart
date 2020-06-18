import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/screens/chat_screen/chat_screen.dart';
import 'package:voices/screens/chat_screen/ui_chat.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'recording_tool.dart';

/// Input section of the chat.
class MessageSendingSection extends StatefulWidget {
  @override
  _MessageSendingSectionState createState() => _MessageSendingSectionState();
}

class _MessageSendingSectionState extends State<MessageSendingSection> {

  /// Handle text field.
  final TextEditingController _messageTextController = TextEditingController();

  /// This is the interface for the cloud.
  CloudFirestoreService cloudFirestoreService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cloudFirestoreService = Provider.of<CloudFirestoreService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<LoggedInUserService>(context, listen: false);
    final screenInfo =
        Provider.of<GlobalChatScreenInfo>(context, listen: false);

    return Column(
      children: <Widget>[

        /// Recording information.
        RecordingAndPlayingInfo(),

        /// Control panel.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            /// Text field.
            Expanded(
                child: SendTextField(
                    controller: _messageTextController,
                    onTextChanged: _onTextChanged)),

            /// Text send button.
            if (_messageTextController.text != '')
              SendTextButton(
                onPress: () async {

                  /// Create message object.
                  TextMessage message = TextMessage(
                      senderUid: authService.loggedInUser.uid,
                      text: _messageTextController.text);

                  /// Send the text message.
                  cloudFirestoreService.addTextMessage(
                      chatId: screenInfo.chatId, textMessage: message);

                  // Clear the text field.
                  _messageTextController.text = '';
                  setState(() {});
                },
              ),

            /// Audio recording controls.
            RecorderControls(),

          ],
        ),
      ],
    );
  }

  /// Update the text field to be displayed.
  _onTextChanged(String newText) {
    setState(() {});
  }
}


