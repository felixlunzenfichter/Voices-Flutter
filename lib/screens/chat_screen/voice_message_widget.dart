import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/voice_message.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/screens/chat_screen/chat_screen.dart';
import 'package:voices/screens/chat_screen/ui_chat.dart';
import 'package:voices/services/CurrentlyListeningInChatsState.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_player_service.dart';
import 'package:voices/services/recorder_service.dart';
import 'recording_tool.dart';
import 'package:voices/services/local_player_service.dart';
import 'package:voices/services/recorder_service.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/services/storage_service.dart';
import 'dart:io';

class NewVoiceMessageInChatWidget extends StatelessWidget {
  final VoiceMessage voiceMessage;

  NewVoiceMessageInChatWidget({@required this.voiceMessage});

  @override
  Widget build(BuildContext context) {
    final CurrentlyListeningInChatState currentlyListeningInChatState =
        Provider.of<CurrentlyListeningInChatState>(context);
    final GlobalChatScreenInfo screenInfo =
        Provider.of<GlobalChatScreenInfo>(context);
    final RecorderService recorderService =
        Provider.of<RecorderService>(context);

    return Row(
      children: <Widget>[
        GestureDetector(
          child: ButtonFromPicture(
            onPress: () async {
              File audioFile = await StorageService()
                  .downloadAudioFile(voiceMessage: voiceMessage);
              Recording recording = Recording(
                  duration: voiceMessage.length, path: audioFile.path);
              currentlyListeningInChatState.playAudioInChat(
                  screenInfo.chatId, recording);
            },
            image: Image.asset('assets/play_1.png'),
          ),
        ),
        Container(child: Text(voiceMessage.length.toString())),
      ],
    );
  }
}

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

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0.0,
      max: widget.duration.inMilliseconds.toDouble(),
      value: _dragValue ?? widget.position.inMilliseconds.toDouble(),
      onChanged: (value) {
        setState(() {
          _dragValue = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged(Duration(milliseconds: value.round()));
        }
      },
      onChangeEnd: (value) {
        _dragValue = null;
        if (widget.onChangeEnd != null) {
          widget.onChangeEnd(Duration(milliseconds: value.round()));
        }
      },
    );
  }
}
