import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:voices/models/recording.dart';

class RecorderService with ChangeNotifier {
  Recording recording;
  RecordingStatus status = RecordingStatus.uninitialized;
  bool get isPaused => _recorder.isPaused;
  bool get isRecording => _recorder.isRecording;
  bool get isStopped => _recorder.isStopped;
  bool get isInitialized =>
      _recorder?.isInited == t_INITIALIZED.FULLY_INITIALIZED;

  RecorderService() {
    _initialize();
  }

  //for internal use
  FlutterSoundRecorder _recorder;
  String _pathToRecording;

  _initialize() async {
    _recorder = await FlutterSoundRecorder().initialize();
    await _recorder.setSubscriptionDuration(0.01);
    await _recorder.setDbPeakLevelUpdate(0.8);
    await _recorder.setDbLevelEnabled(true);
    status = RecordingStatus.initialized;
  }

  @override
  dispose() async {
    await _recorder.release();
    super.dispose();
  }

  start() async {
    Directory tempDir = await getTemporaryDirectory();
    _pathToRecording =
        '${tempDir.path}/${_recorder.slotNo}-flutter_sound_example.aac';
    await _recorder.startRecorder(
      uri: _pathToRecording,
      codec: t_CODEC.CODEC_AAC,
    );
    status = RecordingStatus.recording;
    notifyListeners();
  }

  stop() async {
    await _recorder.stopRecorder();
    await _setRecording();
    status = RecordingStatus.stopped;
    notifyListeners();
  }

  pause() async {
    await _recorder.pauseRecorder();
    await _setRecording();
    status = RecordingStatus.paused;
    notifyListeners();
  }

  resume() async {
    await _recorder.resumeRecorder();
    status = RecordingStatus.recording;
    notifyListeners();
  }

  /// This can only call this after [_recorder.startRecorder()] is done.
  Stream<Duration> getPositionStream() {
    return _recorder.onRecorderStateChanged.map((state) =>
        Duration(milliseconds: state?.currentPosition?.toInt() ?? 0));
  }

  Stream<double> getDbLevelStream() {
    return _recorder.onRecorderDbPeakChanged;
  }

  _setRecording() async {
    int durationInMs = await flutterSoundHelper.duration(_pathToRecording);
    recording = Recording(
        path: _pathToRecording, duration: Duration(milliseconds: durationInMs));
  }
}

enum RecordingStatus { uninitialized, initialized, recording, paused, stopped }
