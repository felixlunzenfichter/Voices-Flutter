import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/screens/conversation_screen/ui_chat.dart';
import 'package:voices/services/logged_in_user_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'recording_section.dart';
import 'package:voices/screens/conversation_screen/conversation_state.dart';
import 'package:voices/screens/conversation_screen/player_widget.dart';

/// This is the control panel for a conversation.
/// When I think control panel I think like star wars control panel.
/// In front of me the world I want to navigate through.
/// Down here the controls.
class ConversationControlPanel extends StatefulWidget {
  @override
  _ConversationControlPanelState createState() =>
      _ConversationControlPanelState();
}

class _ConversationControlPanelState extends State<ConversationControlPanel> {
  /// Handle text field state.
  final TextEditingController _messageTextController = TextEditingController();

  /// This is the interface for the cloud.
  CloudFirestoreService cloudFirestoreService;
  LoggedInUserService userService;
  ConversationState conversationState;

  @override
  void initState() {
    super.initState();
    cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    userService = Provider.of<LoggedInUserService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    conversationState = PropertyChangeProvider.of<ConversationState>(context,
        properties: {MyNotification.InterfaceNotification}).value;
    Interface showInterface = conversationState.showInterface;

    return Column(
      children: <Widget>[
        /// Panel to switch between text input, listening and recording interfaces.
        /// Todo: swipe between sections and chats.
        Row(
          children: <Widget>[
            ControlPanelButton(
                onTap: () {
                  setState(() {
                    conversationState.showTextInputSection();
                  });
                },
                text: 'write',
                color: Colors.yellow),
            ControlPanelButton(
                onTap: () {
                  setState(() {
                    conversationState.showListeningSection();
                  });
                },
                text: 'listen',
                color: Colors.orange),
            ControlPanelButton(
              onTap: () {
                setState(() {
                  conversationState.showRecordingSection();
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
              authService: userService),

        if (showInterface == Interface.Recording)
          RecordingSection(),

        if (showInterface == Interface.Listening)
          ListeningSection(),
      ],
    );
  }
}

/// Record.
class RecordingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        /// Recording information.
        RecordingAndPlayingInfo(),

        // Audio recording controls.
        RecorderControls(),
      ],
    );
  }
}

class ListeningSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ConversationState conversationState =
        PropertyChangeProvider.of<ConversationState>(
      context,
      properties: {MyNotification.playerListeningSectionInitNotification},
    ).value;

    /// Always show the recording we are currently listening to.
    File audioFile = conversationState.listeningTo;

    if (audioFile == null) {
      return Text('Select a recording to play it.');
    } else {
      return PlayerWidget(
        playerService: conversationState.playerListeningSection,
        audioFilePath: audioFile.path,
      );
    }
  }
}

/// Write and send written text.
class TextInputSection extends StatefulWidget {
  final TextEditingController messageTextController;
  final CloudFirestoreService cloudFirestoreService;
  final LoggedInUserService authService;

  TextInputSection(
      {this.messageTextController,
      this.cloudFirestoreService,
      this.authService});

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInputSection> {
  ConversationState screenInfo;

  @override
  void initState() {
    super.initState();
    screenInfo =
        PropertyChangeProvider.of<ConversationState>(context, listen: false)
            .value;
  }

  @override
  Widget build(BuildContext context) {
    print('build');
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
                  chatId: screenInfo.chatId, textMessage: message);

// Clear the text field.
              widget.messageTextController.text = '';
              setState(() {});
            },
          ),
      ],
    );
  }
}

/// Button to switch between writing, listening and recording section.
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
