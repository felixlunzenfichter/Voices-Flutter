import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/voice_message.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/screens/chat_screen/widgets.dart';
import 'package:voices/services/cloud_player_service.dart';

class VoiceMessageContent extends StatefulWidget {
  final VoiceMessage voiceMessage;
  final UniqueKey key;

  VoiceMessageContent({@required this.voiceMessage, @required this.key});

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
        .getPlaybackStateStream(playerId: _playerId);
    _positionStream = cloudPlayerService
        .getPositionStream(playerId: _playerId);
  }

  @override
  void dispose() {
    final cloudPlayerService =
    Provider.of<CloudPlayerService>(context, listen: false);
    cloudPlayerService.disposePlayer(playerId: _playerId);
    super.dispose();
  }

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