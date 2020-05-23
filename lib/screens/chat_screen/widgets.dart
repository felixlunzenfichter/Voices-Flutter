import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/image_message.dart';
import 'package:voices/models/message.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/models/voice_message.dart';
import 'package:voices/services/local_player_service.dart';
import 'package:voices/services/recorder_service.dart';
import 'package:voices/shared_widgets/time_stamp_text.dart';
import 'voice_message_widget.dart';

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

class SendRecordingButton extends StatelessWidget {
  final Function onPress;

  SendRecordingButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.send,
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

///to control the recording process
class RecorderControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recorderService = Provider.of<RecorderService>(context);

    if (recorderService.status == RecordingStatus.uninitialized) {
      return CupertinoActivityIndicator();
    } else if (recorderService.status == RecordingStatus.initialized ||
        recorderService.status == RecordingStatus.stopped) {
      return StartRecordingButton(onPress: recorderService.start);
    } else if (recorderService.status == RecordingStatus.recording) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PauseRecordingButton(onPress: recorderService.pause),
            SendRecordingButton(onPress: recorderService.stop),
          ]);
    } else if (recorderService.status == RecordingStatus.paused) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ResumeRecordingButton(onPress: recorderService.resume),
            SendRecordingButton(onPress: recorderService.stop),
          ]);
    } else {
      print("The recorder controls are in a state they shouldn't be");
      return Container();
    }
  }
}

class RecordingAndPlayingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recorderService = Provider.of<RecorderService>(context);
    if (recorderService.status == RecordingStatus.stopped ||
        recorderService.status == RecordingStatus.paused) {
      return LocalPlayerButtons(
        recording: recorderService.recording,
      );
    } else {
      return RecordingInfo();
    }
  }
}

class RecordingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recorderService = Provider.of<RecorderService>(context);
    if (recorderService.status == RecordingStatus.uninitialized) {
      return Text("Recorder not initialized");
    } else if (recorderService.status == RecordingStatus.initialized) {
      return Text("Recorder initialized");
    } else if (recorderService.status == RecordingStatus.paused ||
        recorderService.status == RecordingStatus.recording) {
      return Column(
        children: <Widget>[
          if (recorderService.status == RecordingStatus.paused)
            Text("Recorder paused")
          else
            Text("Recorder recording"),
          DurationCounter(),
          RecordingBars(),
        ],
      );
    } else if (recorderService.status == RecordingStatus.stopped) {
      return Text("Recorder stopped");
    } else {
      return Container(
        color: Colors.red,
        child: Text("The recorder controls are in a state they shouldn't be"),
      );
    }
  }
}

class DurationCounter extends StatefulWidget {
  @override
  _DurationCounterState createState() => _DurationCounterState();
}

class _DurationCounterState extends State<DurationCounter> {
  Stream<Duration> positionStream;

  @override
  void initState() {
    final recorderService =
        Provider.of<RecorderService>(context, listen: false);
    positionStream = recorderService.getPositionStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: positionStream,
      builder: (context, snapshot) {
        Duration position = snapshot.data;
        return Text(
          "${position?.inSeconds ?? 0}s",
          style: TextStyle(
            fontSize: 35.0,
            color: Colors.black,
          ),
        );
      },
    );
  }
}

class RecordingBars extends StatefulWidget {
  final double height;
  RecordingBars({this.height = 100});

  @override
  _RecordingBarsState createState() => _RecordingBarsState();
}

class _RecordingBarsState extends State<RecordingBars> {
  StreamSubscription<double> dbLevelStreamSubscription;
  List<double> storedDbLevels = [];
  static const double BAR_WIDTH = 3;
  final _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    final recorderService =
        Provider.of<RecorderService>(context, listen: false);
    dbLevelStreamSubscription =
        recorderService.getDbLevelStream().listen((newDbLevel) {
      if (newDbLevel != null) {
        _insertNewDbLevel(newDbLevel: newDbLevel);
        _controller.animateTo(_controller.position.maxScrollExtent,
            duration: RecorderService.UPDATE_DURATION_OF_DB_LEVEL_STREAM,
            curve: Curves.linear);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    dbLevelStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedList(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          controller: _controller,
          key: _listKey,
          scrollDirection: Axis.horizontal,
          initialItemCount: storedDbLevels.length,
          itemBuilder: (context, index, animation) {
            /// This is a value between 0 and 120
            double dbLevel = storedDbLevels[index];
            double heightOfBar = dbLevel / 120 * widget.height;
            return SizeTransition(
              axis: Axis.horizontal,
              sizeFactor: animation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: BAR_WIDTH,
                    height: heightOfBar,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  _insertNewDbLevel({@required double newDbLevel}) {
    storedDbLevels.add(newDbLevel);
    _listKey.currentState.insertItem(storedDbLevels.length - 1,
        duration: Duration(milliseconds: 500));
  }
}

class CloudPlayerButtons extends StatefulWidget {
  final Function({@required double currentSpeed}) play;
  final Function pause;
  final Function({@required Duration position}) seek;
  final Function({@required double speed}) setSpeed;
  final Stream<FullAudioPlaybackState> playBackStateStream;
  final Stream<Duration> positionStream;
  final Duration lengthOfAudio;

  CloudPlayerButtons(
      {@required this.play,
      @required this.pause,
      @required this.seek,
      @required this.setSpeed,
      @required this.playBackStateStream,
      @required this.positionStream,
      @required this.lengthOfAudio});

  @override
  _CloudPlayerButtonsState createState() => _CloudPlayerButtonsState();
}

class _CloudPlayerButtonsState extends State<CloudPlayerButtons> {
  double _currentSpeed = 1;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FullAudioPlaybackState>(
      stream: widget.playBackStateStream,
      builder: (context, snapshot) {
        final fullState = snapshot.data;
        final state = fullState?.state;
        final buffering = fullState?.buffering;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${widget.lengthOfAudio.inSeconds}s"),
            if (state == AudioPlaybackState.connecting || buffering == true)
              Container(
                margin: EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: CupertinoActivityIndicator(),
              )
            else if (state == AudioPlaybackState.playing)
              ButtonFromPicture(
                onPress: widget.pause,
                image: Image.asset('assets/pause_1.png'),
              )
            else
              ButtonFromPicture(
                onPress: () {
                  widget.play(currentSpeed: _currentSpeed);
                },
                image: Image.asset('assets/play_1.png'),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 2 / 7,
              ),
              child: StreamBuilder<Duration>(
                stream: widget.positionStream,
                builder: (context, snapshot) {
                  var position = snapshot.data ?? Duration.zero;
                  if (position > widget.lengthOfAudio) {
                    position = widget.lengthOfAudio;
                  }
                  return SeekBar(
                    duration: widget.lengthOfAudio,
                    position: position,
                    onChangeEnd: (newPosition) {
                      widget.seek(position: newPosition);
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
                  widget.setSpeed(speed: 2);
                } else {
                  setState(() {
                    _currentSpeed = 1;
                  });
                  widget.setSpeed(speed: 1);
                }
              },
              text: "${_currentSpeed.floor().toString()}x",
            ),
          ],
        );
      },
    );
  }
}

class LocalPlayerButtons extends StatefulWidget {
  final Recording recording;

  LocalPlayerButtons({@required this.recording});

  @override
  _LocalPlayerButtonsState createState() => _LocalPlayerButtonsState();
}

class _LocalPlayerButtonsState extends State<LocalPlayerButtons> {
  double _currentSpeed = 1;

  LocalPlayerService playerService;
  Stream<PlayerStatus> _statusStream;
  Stream<Duration> _positionStream;

  @override
  void initState() {
    super.initState();
    playerService = Provider.of<LocalPlayerService>(context, listen: false);
    playerService.initialize(recording: widget.recording);
    _statusStream = playerService.getPlaybackStateStream();
    _positionStream = playerService.getPositionStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerStatus>(
      stream: _statusStream,
      initialData: PlayerStatus.uninitialized,
      builder: (context, snapshot) {
        PlayerStatus status = snapshot.data;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${widget.recording.duration.inSeconds}s"),
            if (status == PlayerStatus.uninitialized)
              Container(
                margin: EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: CupertinoActivityIndicator(),
              )
            else if (status == PlayerStatus.playing)
              ButtonFromPicture(
                onPress: playerService.pause,
                image: Image.asset('assets/pause_1.png'),
              )
            else
              ButtonFromPicture(
                onPress: playerService.play,
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
                  Duration lengthOfAudio = widget.recording.duration;

                  /// This is needed in case the actual audio recording is longer than the duration that the recorder service specified
                  if (position > lengthOfAudio) {
                    position = lengthOfAudio;
                  }
                  return SeekBar(
                    duration: lengthOfAudio,
                    position: position,
                    onChangeEnd: (newPosition) {
                      playerService.seek(position: newPosition);
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
                  playerService.setSpeed(speed: 2);
                } else {
                  setState(() {
                    _currentSpeed = 1;
                  });
                  playerService.setSpeed(speed: 1);
                }
              },
              text: "${_currentSpeed.floor().toString()}x",
            ),
          ],
        );
      },
    );
  }
}

class MessageRow extends StatelessWidget {
  MessageRow({this.message, this.isMe});

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    Widget messageWidget;
    switch (message.messageType) {
      case MessageType.text:
        messageWidget = MessageBubble(
            shouldAlignRight: isMe,
            child: Text(
              (message as TextMessage).text,
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            timestamp: message.timestamp);
        break;
      case MessageType.voice:
        messageWidget = VoiceMessageWidget(
          voiceMessage: (message as VoiceMessage),
          key: ValueKey(message.messageId),
        );
        break;
      case MessageType.image:
        messageWidget = MessageBubble(
            shouldAlignRight: isMe,
            child: Image.network(
              (message as ImageMessage).downloadUrl,
              loadingBuilder: (context, child, progress) {
                return progress == null ? child : CupertinoActivityIndicator();
              },
              width: MediaQuery.of(context).size.width * 2 / 3,
              height: MediaQuery.of(context).size.width * 2 / 3,
              fit: BoxFit.cover,
            ),
            timestamp: message.timestamp);
        break;
      default:
        messageWidget = Text("The message type is unknown");
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: messageWidget,
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

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key key,
    @required this.shouldAlignRight,
    @required this.child,
    @required this.timestamp,
  }) : super(key: key);

  final bool shouldAlignRight;
  final Widget child;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 6 / 7,
      ),
      child: Material(
        borderRadius: shouldAlignRight
            ? BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15))
            : BorderRadius.only(
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)),
        elevation: 0.0,
        color: shouldAlignRight ? Colors.yellow : Colors.teal,
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
