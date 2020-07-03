import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/screens/chat_screen/chat_screen.dart';
import 'package:voices/screens/chat_screen/ui_chat.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'recording_tool.dart';
import 'package:voices/models/recording.dart';

/// This enumeration defines the types of control interfaces available in the chat.
enum Interface { Recoring, Listening, Texting }

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

  /// Decide which controls to show right now.
  Interface showInterface = Interface.Recoring;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<LoggedInUserService>(context, listen: false);
    final screenInfo =
        Provider.of<GlobalChatScreenInfo>(context, listen: false);

    return Column(
      children: <Widget>[
        /// Panel to switch between text input, listening and recording interfaces.
        Row(
          children: <Widget>[
            ControlPanelButton(
                onTap: () {
                  setState(() {
                    showInterface = Interface.Texting;
                  });
                },
                text: 'write',
                color: Colors.yellow),
            ControlPanelButton(
                onTap: () {
                  setState(() {
                    showInterface = Interface.Listening;
                  });
                },
                text: 'listen',
                color: Colors.orange),
            ControlPanelButton(
              onTap: () {
                setState(() {
                  showInterface = Interface.Recoring;
                });
              },
              text: 'record',
              color: Colors.red,
            ),
          ],
        ),

        if (showInterface == Interface.Texting)
          TextInputSection(
              messageTextController: _messageTextController,
              cloudFirestoreService: cloudFirestoreService,
              screenInfo: screenInfo,
              authService: authService),

        if (showInterface == Interface.Recoring)
          RecordingSection(),

        if (showInterface == Interface.Listening)
          ListeningSection()
      ],
    );
  }
}

/// Record
class RecordingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        /// Recording information.
        RecordingAndPlayingInfo(),

        // Audio recording controls.
        RecorderControls()
      ],
    );
  }
}

class ListeningSection extends StatelessWidget {
  final Recording recording;

  ListeningSection({this.recording});

  @override
  Widget build(BuildContext context) {
    if (recording == null) {
      return Text('Select a recording to play it.');
    } else {
      return LocalPlayer(
        recording: recording,
      );
    }
  }
}

/// Write and send written text.
class TextInputSection extends StatefulWidget {
  final TextEditingController messageTextController;
  final CloudFirestoreService cloudFirestoreService;
  final GlobalChatScreenInfo screenInfo;
  final LoggedInUserService authService;

  TextInputSection(
      {this.messageTextController,
      this.cloudFirestoreService,
      this.screenInfo,
      this.authService});

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInputSection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        /// Text field.
        Expanded(
            child: SendTextField(
                controller: widget.messageTextController,
                onTextChanged: (String s) {
                  setState(() {});
                })),

        /// Text send button.
        if (widget.messageTextController.text != '')
          SendTextButton(
            onPress: () async {
              /// Create message object.
              TextMessage message = TextMessage(
                  senderUid: widget.authService.loggedInUser.uid,
                  text: widget.messageTextController.text);

              /// Send the text message.
              widget.cloudFirestoreService.addTextMessage(
                  chatId: widget.screenInfo.chatId, textMessage: message);

// Clear the text field.
              widget.messageTextController.text = '';
              setState(() {});
            },
          ),
      ],
    );
  }
}

class ControlPanelButton extends StatelessWidget {
  final Function onTap;
  final String text;
  final Color color;
  ControlPanelButton({this.onTap, this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          child: Center(child: Text(text)),
          color: color,
          height: 20,
          width: MediaQuery.of(context).size.width / 3,
        ),
        onTap: onTap);
  }
}
