import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/voice_message.dart';
import 'package:voices/screens/conversation_screen/ui_chat.dart';
import 'package:voices/services/logged_in_user_service.dart';
import 'package:voices/services/cloud_storage_service.dart';
import 'dart:io';
import 'package:voices/screens/conversation_screen/conversation_state.dart';

import 'package:voices/services/local_storage.dart';

///
class NewVoiceMessageInChatWidget extends StatelessWidget {
  final VoiceMessage voiceMessage;

  NewVoiceMessageInChatWidget({@required this.voiceMessage});

  @override
  Widget build(BuildContext context) {
    final ConversationState conversationState =
        PropertyChangeProvider.of<ConversationState>(context, listen: false)
            .value;
    final LoggedInUserService loggedInUserService =
        Provider.of<LoggedInUserService>(context, listen: false);
    final CloudStorageService cloudStorageService =
        Provider.of<CloudStorageService>(context, listen: false);

    final isMe = voiceMessage.senderUid == loggedInUserService.loggedInUser.uid;

    return MessageBubble(
      timestamp: voiceMessage.timestamp,
      shouldAlignRight: isMe,
      child: Row(
        children: <Widget>[
          GestureDetector(
            child: ButtonFromPicture(
              onPress: () async {
                /// Todo: Make this a file.

                /// Todo: get from local storage.
//                recording = await localStorageService.getRecording(
//                    voiceMessage: voiceMessage);

                conversationState.showListeningSection();

                /// Todo: Show loading progress in the listening section.
                File audioFile = await cloudStorageService.downloadAudioFile(
                    voiceMessage: voiceMessage);

                conversationState.setListeningTo(audioFile);
                print('Path of voice message: ${audioFile.path}');

                /// Todo: make audioFile specific to chat.
                /// play the voice message.
              },
              image: Image.asset('assets/play_1.png'),
            ),
          ),
          Container(child: Text(voiceMessage.length.toString())),
        ],
      ),
    );
  }
}

/// Todo: Remove this.
/*
class VoiceMessageWidget extends StatefulWidget {
  final VoiceMessage voiceMessage;

  VoiceMessageWidget({Key key, @required this.voiceMessage}) : super(key: key);

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  String _playerId;
  Stream<FullAudioPlaybackState> _playBackStream;
  Stream<Duration> _positionStream;

  @override
  void initState() {
    super.initState();
    _playerId = widget.voiceMessage.messageId;
    final cloudPlayerService =
        Provider.of<CloudPlayerService>(context, listen: false);
    cloudPlayerService.initializePlayerWithUrl(
        url: widget.voiceMessage.downloadUrl, playerId: _playerId);
    _playBackStream =
        cloudPlayerService.getPlaybackStateStream(playerId: _playerId);
    _positionStream = cloudPlayerService.getPositionStream(playerId: _playerId);
  }

  //todo dispose player
//  @override
//  void dispose() {
//    final cloudPlayerService =
//        Provider.of<CloudPlayerService>(context, listen: false);
//    cloudPlayerService.disposePlayer(playerId: _playerId);
//    super.dispose();
//  }

  @override
  Widget build(BuildContext context) {
    final cloudPlayerService =
        Provider.of<CloudPlayerService>(context, listen: false);
    final authService =
        Provider.of<LoggedInUserService>(context, listen: false);
    final isMe = widget.voiceMessage.senderUid == authService.loggedInUser.uid;
    return MessageBubble(
      shouldAlignRight: isMe,
      timestamp: widget.voiceMessage.timestamp,
      child: Container(
        color: Colors.yellow,
        height: 70,
        child: CloudPlayerButtons(
          play: ({@required double currentSpeed}) {
            //todo refactor playercontrols so it works for local and cloud player service and does what is common to them both
            cloudPlayerService.play(playerId: _playerId);
          },
          pause: () {
            cloudPlayerService.pause(playerId: _playerId);
          },
          seek: ({@required Duration position}) {
            cloudPlayerService.seek(position: position, playerId: _playerId);
          },
          setSpeed: ({@required double speed}) {
            cloudPlayerService.setSpeed(speed: speed, playerId: _playerId);
          },
          playBackStateStream: _playBackStream,
          positionStream: _positionStream,
          lengthOfAudio: widget.voiceMessage.length,
        ),
      ),
    );
  }
}

 */
