import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/models/voice_message.dart';
import 'package:voices/screens/chat_screen/message_sending_section.dart';
import 'package:voices/screens/chat_screen/messages.dart';
import 'package:voices/screens/chat_screen/widgets.dart';
import 'package:voices/services/player_service.dart';

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




class VoiceMessageContent extends StatefulWidget {
  final VoiceMessage voiceMessage;

  VoiceMessageContent({@required this.voiceMessage});

  @override
  _VoiceMessageContentState createState() => _VoiceMessageContentState();
}

class _VoiceMessageContentState extends State<VoiceMessageContent> {
  @override
  void initState() {
    super.initState();
    final playerService = Provider.of<PlayerService>(context, listen: false);
    playerService.initializePlayerWithUrl(url: widget.voiceMessage.downloadUrl);
  }

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayerService>(context);
    final double progress =
        playerService.currentPosition.inMilliseconds.toDouble() /
            widget.voiceMessage.length.inMilliseconds.toDouble();
    return Container(
      color: Colors.yellow,
      height: 70,
      child: Row(
        children: <Widget>[
          if (playerService.currentStatus == PlayerStatus.playing)
            ButtonFromPicture(
              onPress: () {
                playerService.pause();
              },
              image: Image.asset('assets/pause_1.png'),
            )
          else
            ButtonFromPicture(
              onPress: () async {
                await playerService.play();
              },
              image: Image.asset('assets/play_1.png'),
            ),
          Expanded(
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey,
              value: progress,
            ),
          ),
          if (playerService.currentStatus == PlayerStatus.playing ||
              playerService.currentStatus == PlayerStatus.paused)
            StopButton(
              onPress: () {
                playerService.stop();
              },
            ),
          SpeedButton(
            onPress: () {
              if (playerService.currentSpeed == 1) {
                playerService.setSpeed(speed: 2);
              } else {
                playerService.setSpeed(speed: 1);
              }
            },
            text: "${playerService.currentSpeed}x",
          ),
          Text(
              "${playerService.currentPosition?.inSeconds ?? 0}s of ${widget.voiceMessage.length.inSeconds}s"),
        ],
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
