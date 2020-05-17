import 'dart:async';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:voices/models/recording.dart';

class NewRecorderService {
  Recording recording;
  bool get isPaused => _recorder.isPaused;
  bool get isRecording => _recorder.isRecording;
  bool get isStopped => _recorder.isStopped;
  bool get isInitialized =>
      _recorder?.isInited == t_INITIALIZED.FULLY_INITIALIZED;

  //for internal use
  FlutterSoundRecorder _recorder;
  StreamController<RecordingStatus> _streamController =
      StreamController<RecordingStatus>.broadcast();
  String _pathToRecording;

  initialize() async {
    if (!isInitialized) {
      //only initialize the recorder if it isn't already
      _recorder = await FlutterSoundRecorder().initialize();
      await _recorder.setSubscriptionDuration(0.01);
      await _recorder.setDbPeakLevelUpdate(0.8);
      await _recorder.setDbLevelEnabled(true);
      _streamController.add(RecordingStatus.initialized);
    }
  }

  dispose() async {
    await _recorder.release();
    _streamController.close();
  }

  start() async {
    Directory tempDir = await getTemporaryDirectory();
    _pathToRecording =
        '${tempDir.path}/${_recorder.slotNo}-flutter_sound_example.aac';
    await _recorder.startRecorder(
      uri: _pathToRecording,
      codec: t_CODEC.CODEC_AAC,
    );
    _streamController.add(RecordingStatus.recording);
  }

  stop() async {
    await _recorder.stopRecorder();
    int durationInMs = await flutterSoundHelper.duration(_pathToRecording);
    recording = Recording(
        path: _pathToRecording, duration: Duration(milliseconds: durationInMs));
    _streamController.add(RecordingStatus.stopped);
  }

  pause() async {
    await _recorder.pauseRecorder();
    _streamController.add(RecordingStatus.paused);
  }

  resume() async {
    await _recorder.resumeRecorder();
    _streamController.add(RecordingStatus.recording);
  }

  ///we can only call this after start() is done
  Stream<Duration> getPositionStream() {
    return _recorder.onRecorderStateChanged.map((state) =>
        Duration(milliseconds: state?.currentPosition?.toInt() ?? 0));
  }

  Stream<double> getDbLevelStream() {
    return _recorder.onRecorderDbPeakChanged;
  }

  Stream<RecordingStatus> getStatusStream() {
    return _streamController.stream;
  }
}

enum RecordingStatus { uninitialized, initialized, recording, paused, stopped }
