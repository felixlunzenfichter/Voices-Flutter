import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/conversation_screen/conversation_screen.dart';
import 'package:voices/screens/conversation_screen/conversation_state.dart';
import 'package:voices/screens/conversation_screen/ui_chat.dart';
import 'package:voices/services/local_player_service.dart';


/// This widget is the interface for the audio player used in the listening section of the chat.
class PlayerWidget<type> extends StatefulWidget {

  final PlayerServiceType playerServiceType ;
  final String audioFilePath;


  PlayerWidget({@required this.playerServiceType, @required this.audioFilePath});

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {

  /// Playback speed.
  double _currentSpeed = 1;
  /// Current position of playback.
  Stream<Duration> _positionStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    LocalPlayerService playerService;
    
    if (widget.playerServiceType == PlayerServiceType.listening) {
      playerService = Provider.of<PlayerListeningSection>(context, listen: true).localPlayerService;
    } else {
      playerService = Provider.of<PlayerRecordingSection>(context, listen: true).localPlayerService;
    }


    PlayerStatus status = playerService.localPlayerStatus;
    _positionStream = playerService.getPositionStream();

    print('playerStatus in Player: $status');
          if (playerService.duration != null) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text("${playerService.duration.inSeconds}s"),

                /// Show loading indicator while player is not ready.
                if (status == PlayerStatus.uninitialized)
                  Container(
                    margin: EdgeInsets.all(8.0),
                    width: 64.0,
                    height: 64.0,
                    child: CupertinoActivityIndicator(),
                  )

                ///
                else
                  if (status == PlayerStatus.playing)
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
                    maxWidth: MediaQuery
                        .of(context)
                        .size
                        .width * 2 / 7,
                  ),
                  child: StreamBuilder<Duration>(
                    stream: playerService.getPositionStream(),
                    builder: (context, snapshot) {
                      var position = snapshot.data ?? Duration.zero;
                      Duration lengthOfAudio = playerService.duration;

                      /// This is needed in case the actual audio recording is longer than the duration that the recorder service specified
                      if (position > lengthOfAudio) {
                        position = lengthOfAudio;
                      }
                      return SeekBar(
                        duration: lengthOfAudio,
                        position: position,
                        onChangeEnd: (newPosition) {
                          print(newPosition);
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
          } else {
            return Text('wait');
          }

  }
}

/// Navigate in the voice message like in Whatsapp.
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
