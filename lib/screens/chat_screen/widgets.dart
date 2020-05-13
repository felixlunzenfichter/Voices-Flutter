import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/image_message.dart';
import 'package:voices/models/message.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/models/voice_message.dart';
import 'package:voices/screens/chat_screen/chat_screen.dart';
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
