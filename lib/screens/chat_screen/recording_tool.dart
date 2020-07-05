import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/models/voice_message.dart';
import 'package:voices/screens/chat_screen/chat_screen.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/services/local_player_service.dart';
import 'package:voices/services/recorder_service.dart';
import 'package:voices/services/storage_service.dart';
import 'voice_message_widget.dart';
import 'ui_chat.dart';
import 'package:voices/constants.dart';
import 'package:voices/services/auth_service.dart';
import 'dart:io';
import 'package:voices/services/CurrentlyListeningInChatsState.dart';

/// This file contains the logic to record and to listen to recorded audio.

/// Send a voice message. Todo: Upload audio to storage.
dynamic sendvm({BuildContext context}) async {

  /// Access Services.
  RecorderService recorderService = Provider.of<RecorderService>(context, listen: false);
  CloudFirestoreService cloudFirestoreServiced = Provider.of<CloudFirestoreService>(context, listen: false);
  GlobalChatScreenInfo screenInfo = Provider.of<GlobalChatScreenInfo>(context, listen: false);
  LoggedInUserService authService = Provider.of<LoggedInUserService>(context, listen: false);
  StorageService storageService = Provider.of<StorageService>(context, listen: false);
  CurrentlyListeningInChatState currentlyListeningInChatState = Provider.of<CurrentlyListeningInChatState>(context, listen: false);

  /// Stop recording. For offline test purposes I display the voice message in the listening section instead of sending it.
  /// For this specific purpose if I don't put await in front of [recorderService.stop()] then the audio message that will
  /// be displayed in the listening section won't be up to date. 
  await recorderService.stop();

  /// Store Audio file in the cloud.

  DateTime timestamp = DateTime.now();

  String firebasePath = 'voice_messages/${screenInfo.chatId}/${timestamp.toString()}';


//  currentlyListeningInChatState.playAudioInChat(screenInfo.chatId, recorderService.recording);
  print(recorderService.recording.path);



  String downloadURL = await storageService.uploadAudioFile(firebasePath: firebasePath, audioFile: File(recorderService.recording.path));

  VoiceMessage voiceMessage = VoiceMessage(senderUid: authService.loggedInUser.uid, timestamp: timestamp, downloadUrl: downloadURL, transcript: 'transcript', length: recorderService.recording.duration, firebasePath: firebasePath);

  print(voiceMessage.firebasePath);
  cloudFirestoreServiced.addVoiceMessage(chatId: screenInfo.chatId, voiceMessage: voiceMessage);
}

/// Control the recording process.
class RecorderControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    /// Access the recorder.
    final recorderService = Provider.of<RecorderService>(context);


    /// Make sure recorder is initialized.
    if (recorderService.status == RecordingStatus.uninitialized) {
      return CupertinoActivityIndicator();

      /// Ready to start recording.
    } else if (recorderService.status == RecordingStatus.initialized ||
        recorderService.status == RecordingStatus.stopped) {
      return StartRecordingButton(onPress: recorderService.start);

      /// Controls shown while recording.
    } else if (recorderService.status == RecordingStatus.recording) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PauseRecordingButton(onPress: recorderService.pause),
            SendRecordingButton(onPress: () {return sendvm(context: context);}),
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

/// This shows information while recording or displays the recorded message when recording is paused before sending.
class RecordingAndPlayingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    /// Access the recorder.
    final recorderService = Provider.of<RecorderService>(context);

    /// Display the current recording recording when done recording.
    if (recorderService.status == RecordingStatus.paused) {
      return LocalPlayer(
        recording: recorderService.recording,
      );

      /// Display information while recording.
    } else {
      return RecordingInfo();
    }

  }
}

/// Show info during recording process.
class RecordingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    /// Get access to the Recorder.
    final recorderService = Provider.of<RecorderService>(context);

    /// Inform that the recorder is not ready.
    if (recorderService.status == RecordingStatus.uninitialized) {
      return Text("Recorder not initialized");

      /// Show that the recorder is ready to be used.
    } else if (recorderService.status == RecordingStatus.initialized) {
      return Text("Recorder initialized");

      /// Show information while recording.
    } else if (recorderService.status == RecordingStatus.paused || recorderService.status == RecordingStatus.recording) {
      return Column(
        children: <Widget>[

          /// Paused recording but not sent yet.
          if (recorderService.status == RecordingStatus.paused)
            Text("Recorder paused")

          /// Show while recording.
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

/// Show how long we have been recording for.
class DurationCounter extends StatefulWidget {
  @override
  _DurationCounterState createState() => _DurationCounterState();
}

class _DurationCounterState extends State<DurationCounter> {

  /// The latest value from [positionStream] will be displayed in seconds.
  Stream<Duration> positionStream;

  @override
  void initState() {

    /// Access the recorder.
    final recorderService = Provider.of<RecorderService>(context, listen: false);

    /// Access current duration.
    positionStream = recorderService.getPositionStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    /// Display the position in seconds.
    return DurationWidget(positionStream: positionStream);
  }
}


/// Visual representation of the audio file.
/// TODO: make visual representation dependent on pitch and make it colorful. 
class RecordingBars extends StatefulWidget {
  final double height = kRecordingVisualheight;

  @override
  _RecordingBarsState createState() => _RecordingBarsState();
}

class _RecordingBarsState extends State<RecordingBars> {
  StreamSubscription<double> dbLevelStreamSubscription;
  List<double> storedDbLevels = [];
  static const double BAR_WIDTH = 5;
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
    return RecordingBarsWidget(height: widget.height, controller: _controller, listKey: _listKey, storedDbLevels: storedDbLevels, barWidth: BAR_WIDTH);
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