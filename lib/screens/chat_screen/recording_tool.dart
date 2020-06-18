import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/services/local_player_service.dart';
import 'package:voices/services/recorder_service.dart';
import 'voice_message_widget.dart';
import 'ui_chat.dart';


/// Control the recording process.
class RecorderControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    /// Access the recorder.
    final recorderService = Provider.of<RecorderService>(context);

    /// Make sure recorder is initialized.
    if (recorderService.status == RecordingStatus.uninitialized) {
      return CupertinoActivityIndicator();


      /// TODO: Do we need .inilialized here? .uninitialized and .inialized should be complementary.
    } else if (recorderService.status == RecordingStatus.initialized ||
        recorderService.status == RecordingStatus.stopped) {
      return StartRecordingButton(onPress: recorderService.start);

      /// Controls shown while recording.
    } else if (recorderService.status == RecordingStatus.recording) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PauseRecordingButton(onPress: recorderService.pause),
            SendRecordingButton(onPress: recorderService.stop),
          ]);

      /// Controls shown while recording is paused.
    } else if (recorderService.status == RecordingStatus.paused) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ResumeRecordingButton(onPress: recorderService.resume),
            SendRecordingButton(onPress: recorderService.stop),
          ]);

      /// Invalid state. Throw an error.
    } else {
      print("The recorder controls are in a state they shouldn't be in.");
      throw("The recorder controls are in a state they shouldn't be in.");
//      return Container();
    }
  }
}

/// This shows information while recording.
class RecordingAndPlayingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    /// Access the recorder.
    final recorderService = Provider.of<RecorderService>(context);

    /// Display the current recording when done recording.
    if (recorderService.status == RecordingStatus.stopped ||
        recorderService.status == RecordingStatus.paused) {
      return LocalPlayerButtons(
        recording: recorderService.recording,
      );

      /// Display information while recording.
    } else {
      return RecordingInfo();
    }

  }
}

/// This displays information about the current recording before sending it.
/// During recording and after recording ist completed before sending the voice message.
class RecordingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    /// Get access to the Recorder.
    final recorderService = Provider.of<RecorderService>(context);

    /// Show that the recorder is not ready.
    if (recorderService.status == RecordingStatus.uninitialized) {
      return Text("Recorder not initialized");

      /// Show that the recorder is ready to be used.
    } else if (recorderService.status == RecordingStatus.initialized) {
      return Text("Recorder initialized");

      /// Show information while recording or when done recording before sending.
    } else if (recorderService.status == RecordingStatus.paused ||
        recorderService.status == RecordingStatus.recording) {
      return Column(
        children: <Widget>[
          if (recorderService.status == RecordingStatus.paused)
            Text("Recorder paused")
          else

            Text("Recorder recording"),

          /// Show length of current recording.
          DurationCounter(),

          /// Show volume of current recording.
          RecordingBars(),

        ],
      );

      /// Display recorder has stopped.
    } else if (recorderService.status == RecordingStatus.stopped) {
      return Text("Recorder stopped");


      /// In case we reach a state that has not been anticipated throw an error.
    } else {
      return Container(
        color: Colors.red,
        child: Text("The recorder controls are in a state they shouldn't be"),
      );
    }

  }
}

/// Show the duration  of the current voice message.
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