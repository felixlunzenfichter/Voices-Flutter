import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/screens/chat_screen/ui_chat.dart';
import 'package:voices/screens/chat_screen/voice_message_widget.dart';
import 'package:voices/services/CurrentlyListeningInChatsState.dart';
import 'package:voices/services/local_player_service.dart';


/// Play a local audio file.
class LocalPlayer extends StatefulWidget {

  /// Audio file to be played.
  final Recording recording;

  LocalPlayer({@required this.recording});

  @override
  _LocalPlayerState createState() => _LocalPlayerState();
}

class _LocalPlayerState extends State<LocalPlayer> {

  /// Playback speed.
  double _currentSpeed = 1;

  /// Player for local files.
  LocalPlayerService playerService;

  Stream<PlayerStatus> _statusStream;

  /// Current position of playback.
  Stream<Duration> _positionStream;



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CurrentlyListeningInChatState currentlyListeningInChatState = Provider.of<CurrentlyListeningInChatState>(context);

    playerService = Provider.of<LocalPlayerService>(context);
    playerService.initialize(recording: widget.recording);
    _statusStream = playerService.getPlaybackStateStream();
    _positionStream = playerService.getPositionStream();

    return StreamBuilder<PlayerStatus>(
      stream: _statusStream,
      initialData: PlayerStatus.paused,
      builder: (context, snapshot) {
        PlayerStatus status = snapshot.data;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${widget.recording.duration.inSeconds}s"),

            /// Show loading indicator while player is not ready.
            if (status == PlayerStatus.uninitialized)
              Container(
                margin: EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: CupertinoActivityIndicator(),
              )

            ///
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