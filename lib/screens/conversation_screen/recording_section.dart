import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/local_player_service.dart';
import 'package:voices/services/recorder_service.dart';
import 'ui_chat.dart';
import 'package:voices/constants.dart';
import 'package:voices/services/sendVoiceMessage.dart';
import 'package:voices/screens/conversation_screen/player_widget.dart';
import 'package:voices/screens/conversation_screen/conversation_state.dart';

/// This file contains the interface and logic to record and to listen to recorded audio.

/// Control the recording process.
class RecorderControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// Access the recorder.

    final ConversationState conversationState =
        PropertyChangeProvider.of<ConversationState>(context,
            properties: {MyNotification.RecorderNotification}).value;
    final RecorderService recorderService = conversationState.recorderService;
    print('Rebuild Recordercontrols');

    /// Make sure recorder is initialized.
    if (recorderService.status == RecordingStatus.uninitialized) {
      return CupertinoActivityIndicator();

      /// Ready to start recording.
    } else if (recorderService.status == RecordingStatus.initialized ||
        recorderService.status == RecordingStatus.stopped) {
      return StartRecordingButton(
        onPress: () {
          recorderService.start();
        },
      );

      /// Controls shown while recording.
    } else if (recorderService.status == RecordingStatus.recording) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PauseRecordingButton(onPress: () {
              recorderService.pause();
            }),
            StopButton(onPress: () async {
              await recorderService.stop();
            }),
            SendRecordingButton(onPress: () async {
              await recorderService.stop();
              sendvm(context: context);
            }),
          ]);

      /// Controls shown while recording is paused.
    } else if (recorderService.status == RecordingStatus.paused) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ResumeRecordingButton(onPress: recorderService.resume),
            StopButton(onPress: () async {
              await recorderService.stop();
            }),
            SendRecordingButton(onPress: () async {
              await recorderService.stop();
              sendvm(context: context);
            }),
          ]);

      /// Invalid state. Throw an error.
    } else {
      print("The recorder controls are in a state they shouldn't be in.");
      throw ("The recorder controls are in a state they shouldn't be in.");
//      return Container();
    }
  }
}

/// This shows information while recording or displays the recorded message when recording is paused before sending.
class RecordingAndPlayingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    localPlayerService.initialize(recording: recorderService.recording);
    ConversationState conversationState =
        PropertyChangeProvider.of<ConversationState>(context,
            properties: {MyNotification.RecorderNotification}).value;
    print(
        'State of recorder when rebuilding RecordingAndPlayingInfo ${conversationState.recorderService.status}');

    /// Display the current recording recording when done recording.
    if (conversationState.recorderService.status == RecordingStatus.paused) {
      print(
          'Build Player in Recording section with recording: ${conversationState.recorderService.pathToSavedRecording}');
      return PlayerWidget(
        playerService: conversationState.playerRecordingSection,
        audioFilePath: conversationState.recorderService.pathToSavedRecording,
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
    final ConversationState conversationState =
        PropertyChangeProvider.of<ConversationState>(context,
            properties: {MyNotification.RecorderNotification}).value;
    final recorderService = conversationState.recorderService;

    /// Inform that the recorder is not ready.
    if (recorderService.status == RecordingStatus.uninitialized) {
      return Text("Recorder not initialized");

      /// Show that the recorder is ready to be used.
    } else if (recorderService.status == RecordingStatus.initialized) {
      return Text("Recorder initialized");

      /// Show information while recording.
    } else if (recorderService.status == RecordingStatus.paused ||
        recorderService.status == RecordingStatus.recording) {
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
          Text('hi'),
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
    final ConversationState conversationState =
        PropertyChangeProvider.of<ConversationState>(context, listen: false)
            .value;

    /// Access current duration.
    positionStream = conversationState.recorderService.getPositionStream();
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
    final ConversationState conversationState =
        PropertyChangeProvider.of<ConversationState>(context, listen: false)
            .value;
    final recorderService = conversationState.recorderService;
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
    return RecordingBarsWidget(
        height: widget.height,
        controller: _controller,
        listKey: _listKey,
        storedDbLevels: storedDbLevels,
        barWidth: BAR_WIDTH);
  }

  _insertNewDbLevel({@required double newDbLevel}) {
    storedDbLevels.add(newDbLevel);
    _listKey.currentState.insertItem(storedDbLevels.length - 1,
        duration: Duration(milliseconds: 500));
  }
}
