import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/screens/chat_screen/widgets.dart';
import 'package:voices/services/local_player_service.dart';
import 'package:voices/services/new_recorder_service.dart';

class FlutterSoundRecorderExample extends StatefulWidget {
  @override
  _FlutterSoundRecorderExampleState createState() =>
      new _FlutterSoundRecorderExampleState();
}

class _FlutterSoundRecorderExampleState
    extends State<FlutterSoundRecorderExample> {
  Stream<RecordingStatus> statusStream;
  bool _isDoneRecording = false;
  NewRecorderService newRecorderService;

  @override
  void initState() {
    super.initState();
    newRecorderService =
        Provider.of<NewRecorderService>(context, listen: false);
    newRecorderService.initialize();
    statusStream = newRecorderService.getStatusStream();
  }

  @override
  void dispose() {
    super.dispose();
    newRecorderService.dispose();
  }

  void startRecorder() async {
    try {
      await newRecorderService.start();
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  void stopRecorder() async {
    try {
      await newRecorderService.stop();
    } catch (err) {
      print('stopRecorder error: $err');
    }
    setState(() {
      _isDoneRecording = true;
    });
  }

  void pauseResumeRecorder() {
    if (newRecorderService.getIsPaused()) {
      {
        newRecorderService.resume();
      }
    } else {
      newRecorderService.pause();
    }
  }

  void Function() onPauseResumeRecorderPressed() {
    if (newRecorderService.getIsPaused() ||
        newRecorderService.getIsRecording()) {
      return pauseResumeRecorder;
    }
    return null;
  }

  void Function() startStopRecorder() {
    if (newRecorderService.getIsRecording() || newRecorderService.getIsPaused())
      stopRecorder();
    else
      startRecorder();
  }

  void Function() onStartRecorderPressed() {
    return startStopRecorder;
  }

  AssetImage recorderAssetImage() {
    if (onStartRecorderPressed() == null)
      return AssetImage('res/icons/ic_mic_disabled.png');
    return (newRecorderService.getIsStopped())
        ? AssetImage('res/icons/ic_mic.png')
        : AssetImage('res/icons/ic_stop.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Sound'),
      ),
      body: ListView(
        children: <Widget>[
          StreamBuilder(
              stream: statusStream,
              initialData: RecordingStatus.uninitialized,
              builder: (context, snapshot) {
                RecordingStatus currentStatus = snapshot.data;
                if (currentStatus == RecordingStatus.uninitialized) {
                  return Container();
                } else {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (currentStatus == RecordingStatus.recording)
                          Container(
                            margin: EdgeInsets.only(top: 12.0, bottom: 16.0),
                            child: DurationCounter(),
                          ),
                        if (currentStatus == RecordingStatus.recording)
                          DBLevelDisplay(),
                        Row(
                          children: <Widget>[
                            Container(
                              width: 56.0,
                              height: 50.0,
                              child: ClipOval(
                                child: FlatButton(
                                  onPressed: onStartRecorderPressed(),
                                  padding: EdgeInsets.all(8.0),
                                  child: Image(
                                    image: recorderAssetImage(),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 56.0,
                              height: 50.0,
                              child: ClipOval(
                                child: FlatButton(
                                  onPressed: onPauseResumeRecorderPressed(),
                                  disabledColor: Colors.white,
                                  padding: EdgeInsets.all(8.0),
                                  child: Image(
                                    width: 36.0,
                                    height: 36.0,
                                    image: AssetImage(
                                        onPauseResumeRecorderPressed() != null
                                            ? 'res/icons/ic_pause.png'
                                            : 'res/icons/ic_pause_disabled.png'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ]);
                }
              }),
          if (_isDoneRecording)
            PlayerSection(
              recording: newRecorderService.recording,
            ),
        ],
      ),
    );
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
    final newRecorderService =
        Provider.of<NewRecorderService>(context, listen: false);
    positionStream = newRecorderService.getPositionStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StreamBuilder(
          stream: positionStream,
          builder: (context, snapshot) {
            Duration position = snapshot.data;
            return Text(
              position?.toString() ?? '0s',
              style: TextStyle(
                fontSize: 35.0,
                color: Colors.black,
              ),
            );
          },
        ),
      ],
    );
  }
}

class DBLevelDisplay extends StatefulWidget {
  @override
  _DBLevelDisplayState createState() => _DBLevelDisplayState();
}

class _DBLevelDisplayState extends State<DBLevelDisplay> {
  Stream<double> dbLevelStream;

  @override
  void initState() {
    final newRecorderService =
        Provider.of<NewRecorderService>(context, listen: false);
    dbLevelStream = newRecorderService.getDbLevelStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dbLevelStream,
      builder: (context, snapshot) {
        double dbLevel = snapshot.data;
        return LinearProgressIndicator(
            value: 100.0 / 160.0 * (dbLevel ?? 1) / 100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            backgroundColor: Colors.red);
      },
    );
  }
}

class PlayerSection extends StatefulWidget {
  final Recording recording;

  PlayerSection({@required this.recording});

  @override
  _PlayerSectionState createState() => _PlayerSectionState();
}

class _PlayerSectionState extends State<PlayerSection> {
  bool isInitialized = false;
  Stream<Duration> positionStream;
  Stream<FullAudioPlaybackState> playBackStateStream;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Text("Player is not initialized yet");
    } else {
      final playerService =
          Provider.of<LocalPlayerService>(context, listen: false);
      return PlayerControls(
          play: playerService.play,
          pause: playerService.pause,
          seek: playerService.seek,
          setSpeed: ({@required double speed}) {
            playerService.setSpeed(
                speed: speed, shouldBePlayingAfterSpeedIsSet: true);
          },
          playBackStateStream: playBackStateStream,
          positionStream: positionStream,
          lengthOfAudio: widget.recording.duration);
    }
  }

  _initialize() async {
    final playerService =
        Provider.of<LocalPlayerService>(context, listen: false);
    await playerService.initializePlayer(recording: widget.recording);
    setState(() {
      isInitialized = true;
    });
    positionStream = playerService.getPositionStream();
    playBackStateStream = playerService.getPlaybackStateStream();
  }
}
