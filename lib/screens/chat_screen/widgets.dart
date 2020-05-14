import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/image_message.dart';
import 'package:voices/models/message.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/models/voice_message.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/services/cloud_player_service.dart';
import 'package:voices/services/player_service.dart';
import 'package:voices/shared_widgets/time_stamp_text.dart';
import 'package:voices/services/recorder_service.dart';

class SendTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function onTextChanged;

  SendTextField({@required this.controller, @required this.onTextChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        onChanged: onTextChanged,
        controller: controller,
      ),
    );
  }
}

// Button in message sending section that uses self made icons.
class ButtonFromPicture extends StatelessWidget {
  final Function onPress;
  final Image image;

  ButtonFromPicture({@required this.onPress, @required this.image});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(0),
      onPressed: onPress,
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: ShapeDecoration(color: Colors.white, shape: CircleBorder()),
        child: image,
        height: 50.0,
        width: 50.0,
      ),
    );
  }
}

class SendTextButton extends StatelessWidget {
  final Function onPress;

  SendTextButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.send,
    );
  }
}

class StartRecordingButton extends StatelessWidget {
  final Function onPress;

  StartRecordingButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.mic,
    );
  }
}

class PauseRecordingButton extends StatelessWidget {
  final Function onPress;

  PauseRecordingButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.pause,
    );
  }
}

class ResumeRecordingButton extends StatelessWidget {
  final Function onPress;

  ResumeRecordingButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.play_arrow,
    );
  }
}

class StopRecordingButton extends StatelessWidget {
  final Function onPress;

  StopRecordingButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.stop,
    );
  }
}

class SpeedButton extends StatelessWidget {
  final Function onPress;
  final String text;

  SpeedButton({@required this.onPress, @required this.text});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(0),
      onPressed: onPress,
      child: Container(
        padding: EdgeInsets.all(9),
        decoration:
            ShapeDecoration(color: Colors.tealAccent, shape: CircleBorder()),
        child: Text(
          text,
        ),
      ),
    );
  }
}

class PauseButton extends StatelessWidget {
  final Function onPress;

  PauseButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.pause,
    );
  }
}

class StopButton extends StatelessWidget {
  final Function onPress;

  StopButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.stop,
    );
  }
}

class ActivateDirectSendButton extends StatelessWidget {
  final Function onPress;

  ActivateDirectSendButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.all_out,
    );
  }
}

class PlayButton extends StatelessWidget {
  final Function onPress;

  PlayButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.play_arrow,
    );
  }
}

class RecordingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recorderService = Provider.of<RecorderService>(context);
    if (recorderService.currentStatus == RecordingStatus.Recording) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                "Is recording: ${recorderService.currentRecording?.duration?.inSeconds.toString()}s"),
            CupertinoActivityIndicator()
          ]);
    } else if (recorderService.currentStatus == RecordingStatus.Paused) {
      return Text(
          "Is paused: ${recorderService.currentRecording?.duration?.inSeconds.toString()}s");
    } else {
      return Container();
    }
  }
}

class PlayerInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayerService>(context);
    final Duration lengthOfAudio = playerService.audioChunk.length;
    final double progress =
        playerService.currentPosition.inMilliseconds.toDouble() /
            lengthOfAudio.inMilliseconds.toDouble();
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
              "${playerService.currentPosition.inSeconds}s of ${playerService.audioChunk.length.inSeconds}s"),
        ],
      ),
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
        // a column with just one child because I haven't figure out how else to size the bubble to fit its contents instead of filling it
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          if (message.messageType == MessageType.text)
            MessageBubble(
                isMe: isMe,
                child: Text(
                  (message as TextMessage).text,
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                timestamp: message.timestamp),
          if (message.messageType == MessageType.voice)
            MessageBubble(
                isMe: isMe,
                child: VoiceMessageContent(
                  voiceMessage: (message as VoiceMessage),
                  key: ObjectKey(message as VoiceMessage),
                ),
                timestamp: message.timestamp),
          if (message.messageType == MessageType.image)
            MessageBubble(
                isMe: isMe,
                child: Image.network(
                  (message as ImageMessage).downloadUrl,
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CupertinoActivityIndicator();
                  },
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  height: MediaQuery.of(context).size.width * 2 / 3,
                  fit: BoxFit.cover,
                ),
                timestamp: message.timestamp),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key key,
    @required this.isMe,
    @required this.child,
    @required this.timestamp,
  }) : super(key: key);

  final bool isMe;
  final Widget child;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 6 / 7,
      ),
      child: Material(
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
              child,
              SizedBox(
                width: 10,
              ),
              TimeStampText(timestamp: timestamp)
            ],
          ),
        ),
      ),
    );
  }
}

class RoundButton extends StatelessWidget {
  final Function onPress;
  final IconData iconData;

  RoundButton({@required this.iconData, @required this.onPress});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(0),
      onPressed: onPress,
      child: Container(
        padding: EdgeInsets.all(9),
        decoration:
            ShapeDecoration(color: Colors.tealAccent, shape: CircleBorder()),
        child: Icon(
          iconData,
          color: Colors.brown,
          size: 22,
        ),
      ),
    );
  }
}

class VoiceMessageContent extends StatefulWidget {
  final VoiceMessage voiceMessage;

  VoiceMessageContent({@required this.voiceMessage, @required Key key})
      : super(key: key);

  @override
  _VoiceMessageContentState createState() => _VoiceMessageContentState();
}

class _VoiceMessageContentState extends State<VoiceMessageContent> {
  String _playerId;
  Stream<FullAudioPlaybackState> _playBackStream;
  Stream<Duration> _positionStream;
  double _currentSpeed = 1;

  @override
  void initState() {
    super.initState();
    _playerId = widget.voiceMessage.messageId;
    final cloudPlayerService =
        Provider.of<CloudPlayerService>(context, listen: false);
    cloudPlayerService.initializePlayerWithUrl(
        url: widget.voiceMessage.downloadUrl, playerId: _playerId);
    _playBackStream = cloudPlayerService
        .getPlaybackStateStream(playerId: _playerId)
        .asBroadcastStream();
    _positionStream = cloudPlayerService
        .getPositionStream(playerId: _playerId)
        .asBroadcastStream();
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
    return Container(
      color: Colors.yellow,
      height: 70,
      child: StreamBuilder<FullAudioPlaybackState>(
        stream: _playBackStream,
        builder: (context, snapshot) {
          final fullState = snapshot.data;
          final state = fullState?.state;
          final buffering = fullState?.buffering;
          final lengthOfAudio = widget.voiceMessage.length;
          print("state of the playback is = $state");

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${widget.voiceMessage.length.inSeconds}s"),
              if (state == AudioPlaybackState.connecting || buffering == true)
                Container(
                  margin: EdgeInsets.all(8.0),
                  width: 64.0,
                  height: 64.0,
                  child: CupertinoActivityIndicator(),
                )
              else if (state == AudioPlaybackState.playing)
                ButtonFromPicture(
                  onPress: () async {
                    await cloudPlayerService.pause(playerId: _playerId);
                  },
                  image: Image.asset('assets/pause_1.png'),
                )
              else
                ButtonFromPicture(
                  onPress: () async {
                    await cloudPlayerService.play(playerId: _playerId);
                  },
                  image: Image.asset('assets/play_1.png'),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 2 / 7,
                ),
                child: StreamBuilder<Duration>(
                  stream: _positionStream,
                  builder: (context, snapshot) {
                    var position = snapshot.data ?? Duration.zero;
                    if (position > lengthOfAudio) {
                      position = lengthOfAudio;
                    }
                    return SeekBar(
                      duration: lengthOfAudio,
                      position: position,
                      onChangeEnd: (newPosition) async {
                        await cloudPlayerService.seek(
                            position: newPosition, playerId: _playerId);
                      },
                    );
                  },
                ),
              ),
              SpeedButton(
                onPress: () {
                  if (_currentSpeed == 1) {
                    setState(() {
                      _currentSpeed = 2;
                    });
                    cloudPlayerService.setSpeed(speed: 2, playerId: _playerId);
                  } else {
                    setState(() {
                      _currentSpeed = 1;
                    });
                    cloudPlayerService.setSpeed(speed: 1, playerId: _playerId);
                  }
                },
                text: "${_currentSpeed.floor().toString()}x",
              ),
//              if (!(state == AudioPlaybackState.stopped ||
//                  state == AudioPlaybackState.none))
//                StopButton(
//                  onPress: () async {
//                    await cloudPlayerService.stop(playerId: _playerId);
//                  },
//                ),
            ],
          );
        },
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
