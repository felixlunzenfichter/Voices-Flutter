import 'dart:async';
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/screens/chat_screen/widgets.dart';
import 'package:voices/services/local_player_service.dart';

class FlutterSoundRecorderExample extends StatefulWidget {
  @override
  _FlutterSoundRecorderExampleState createState() =>
      new _FlutterSoundRecorderExampleState();
}

class _FlutterSoundRecorderExampleState
    extends State<FlutterSoundRecorderExample> {
  //for UI
  bool _isRecording = false;
  bool _isDoneRecording = false;
  Duration _lengthOfRecording;
  String _pathOfRecording;
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  FlutterSoundRecorder recorderModule;
  double _dbLevel;

  Future<void> _initializeExample() async {
    await recorderModule.setSubscriptionDuration(0.01);
  }

  Future<void> init() async {
    recorderModule = await FlutterSoundRecorder().initialize();
    await _initializeExample();

    await recorderModule.setDbPeakLevelUpdate(0.8);
    await recorderModule.setDbLevelEnabled(true);
    await recorderModule.setDbLevelEnabled(true);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
    if (_dbPeakSubscription != null) {
      _dbPeakSubscription.cancel();
      _dbPeakSubscription = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelRecorderSubscriptions();
    releaseFlauto();
  }

  Future<void> releaseFlauto() async {
    try {
      await recorderModule.release();
    } catch (e) {
      print('Released unsuccessful');
      print(e);
    }
  }

  void startRecorder() async {
    try {
      Directory tempDir = await getTemporaryDirectory();

      _pathOfRecording = await recorderModule.startRecorder(
        uri:
            '${tempDir.path}/${recorderModule.slotNo}-flutter_sound_example.aac',
        codec: t_CODEC.CODEC_AAC,
      );

      _recorderSubscription = recorderModule.onRecorderStateChanged.listen((e) {
        if (e != null && e.currentPosition != null) {
          this.setState(() {
            _lengthOfRecording =
                Duration(milliseconds: e.currentPosition.toInt());
          });
        }
      });
      _dbPeakSubscription =
          recorderModule.onRecorderDbPeakChanged.listen((value) {
        setState(() {
          this._dbLevel = value;
        });
      });

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
      setState(() {
        stopRecorder();
        this._isRecording = false;
        if (_recorderSubscription != null) {
          _recorderSubscription.cancel();
          _recorderSubscription = null;
        }
        if (_dbPeakSubscription != null) {
          _dbPeakSubscription.cancel();
          _dbPeakSubscription = null;
        }
      });
    }
  }

  void stopRecorder() async {
    try {
      String result = await recorderModule.stopRecorder();
      print('stopRecorder: $result');
      cancelRecorderSubscriptions();
    } catch (err) {
      print('stopRecorder error: $err');
    }
    this.setState(() {
      this._isRecording = false;
      this._isDoneRecording = true;
    });
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  // In this simple example, we just load a file in memory.This is stupid but just for demonstration  of startPlayerFromBuffer()
  Future<Uint8List> makeBuffer(String path) async {
    try {
      if (!await fileExists(path)) return null;
      File file = File(path);
      file.openRead();
      var contents = await file.readAsBytes();
      print('The file is ${contents.length} bytes long.');
      return contents;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void pauseResumeRecorder() {
    if (recorderModule.isPaused) {
      {
        recorderModule.resumeRecorder();
      }
    } else {
      recorderModule.pauseRecorder();
    }
  }

  void Function() onPauseResumeRecorderPressed() {
    if (recorderModule == null) return null;
    if (recorderModule.isPaused || recorderModule.isRecording) {
      return pauseResumeRecorder;
    }
    return null;
  }

  void Function() startStopRecorder() {
    if (recorderModule.isRecording || recorderModule.isPaused)
      stopRecorder();
    else
      startRecorder();
  }

  void Function() onStartRecorderPressed() {
    //if (_media == t_MEDIA.ASSET || _media == t_MEDIA.BUFFER || _media == t_MEDIA.REMOTE_EXAMPLE_FILE) return null;
    // Disable the button if the selected codec is not supported
    if (recorderModule == null) return null;
    return startStopRecorder;
  }

  AssetImage recorderAssetImage() {
    if (onStartRecorderPressed() == null)
      return AssetImage('res/icons/ic_mic_disabled.png');
    return (recorderModule.isStopped)
        ? AssetImage('res/icons/ic_mic.png')
        : AssetImage('res/icons/ic_stop.png');
  }

  @override
  Widget build(BuildContext context) {
    Widget recorderSection = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 12.0, bottom: 16.0),
            child: Text(
              this._lengthOfRecording?.toString() ?? '0s',
              style: TextStyle(
                fontSize: 35.0,
                color: Colors.black,
              ),
            ),
          ),
          _isRecording
              ? LinearProgressIndicator(
                  value: 100.0 / 160.0 * (this._dbLevel ?? 1) / 100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  backgroundColor: Colors.red)
              : Container(),
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
                      image: AssetImage(onPauseResumeRecorderPressed() != null
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Sound'),
      ),
      body: ListView(
        children: <Widget>[
          recorderSection,
          if (_isDoneRecording)
            PlayerSection(
              recording: Recording(
                  path: _pathOfRecording, duration: _lengthOfRecording),
            ),
        ],
      ),
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
