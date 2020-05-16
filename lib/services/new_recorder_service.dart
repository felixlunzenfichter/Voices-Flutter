import 'dart:async';
import 'package:voices/models/recording.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
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
import 'package:voices/services/new_recorder_service.dart';

class NewRecorderService {
  FlutterSoundRecorder recorderModule;

//  initialize() async {
//    recorderModule = await FlutterSoundRecorder().initialize();
//    await recorderModule.setSubscriptionDuration(0.01);
//    await recorderModule.setDbPeakLevelUpdate(0.8);
//    await recorderModule.setDbLevelEnabled(true);
//    await recorderModule.setDbLevelEnabled(true);
//  }
//
//  dispose() async {
//    await recorderModule.release();
//  }
//
//  start({@required String pathOfRecording}) async {
//    return await recorderModule.startRecorder(
//      uri: pathOfRecording,
//      codec: t_CODEC.CODEC_AAC,
//    );
//  }
//
//  stop() async {
//    await recorderModule.stopRecorder();
//  }
//
//  bool getIsPaused() {
//    return recorderModule.isPaused;
//  }
//
//  bool getIsRecording() {
//    return recorderModule.isRecording;
//  }
//
//  bool getIsStopped() {
//    return recorderModule.isStopped;
//  }
//
//  pause() async {
//    await recorderModule.pauseRecorder();
//  }
//
//  resume() async {
//    await recorderModule.resumeRecorder();
//  }
//
//  Stream<RecordStatus> getPositionStream() {
//    return recorderModule.onRecorderStateChanged;
//  }
//
//  Stream<double> getDbLevelStream() {
//    return recorderModule.onRecorderDbPeakChanged;
//  }
}

enum RecordingStatus { initialized, recording, paused, stopped }
