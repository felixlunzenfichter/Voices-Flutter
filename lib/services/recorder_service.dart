import 'dart:async';
import 'dart:io';
import 'package:voices/models/recording.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';

class RecorderService {
  Recording recording;

  initialize() async {
    await _initializeRecorder();
    await _initializeFileLocation();
    _streamController.add(RecordingStatus.initialized);
  }

  dispose() async {
    try {
      await _recorder.release();
      await _streamController.close();
    } catch (e) {
      print('Could not release recorder because of error = $e');
    }
  }

  start() async {
    try {
      _streamController.add(RecordingStatus.recording);
      await _recorder.startRecorder(
        uri: _pathOfRecording,
        codec: _codec,
      );
    } catch (e) {
      print("Could not start recording because of error = $e");
    }
  }

  pause() {
    try {
      _streamController.add(RecordingStatus.paused);
      _recorder.pauseRecorder();
    } catch (e) {
      print("Could not pause recording because of error = $e");
    }
  }

  resume() {
    try {
      _streamController.add(RecordingStatus.recording);
      _recorder.resumeRecorder();
    } catch (e) {
      print("Could not resume recording because of error = $e");
    }
  }

  stop() async {
    try {
      _streamController.add(RecordingStatus.stopped);
      await _recorder.stopRecorder();
      int lengthOfRecordingInMilliseconds = await flutterSoundHelper
          .duration(_pathOfRecording); //this is an estimate
      recording = Recording(
          path: _pathOfRecording,
          duration: Duration(milliseconds: lengthOfRecordingInMilliseconds));
    } catch (e) {
      print("Could not stop recorder because of error: $e");
      return null;
    }
  }

  Stream<Duration> getRecorderPositionStream() {
    try {
      return _recorder.onRecorderStateChanged.map(
          (state) => Duration(milliseconds: state.currentPosition.toInt()));
    } catch (e) {
      print("Could not get recorder position because of error: $e");
      return null;
    }
  }

  Stream<RecordingStatus> getRecorderStatusStream() {
    try {
      return _streamController.stream.asBroadcastStream();
    } catch (e) {
      print("Could not get recorder status because of error: $e");
      return null;
    }
  }

  _initializeRecorder() async {
    _recorder = await FlutterSoundRecorder().initialize();
    await _recorder.setSubscriptionDuration(0.01);
    await _recorder.setDbPeakLevelUpdate(0.8);
    await _recorder.setDbLevelEnabled(true);
    await _recorder.setDbLevelEnabled(true);
  }

  _initializeFileLocation() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      _pathOfRecording =
          '${tempDir.path}/${_recorder.slotNo}-voice_message_recording${_fileExtensions[_codec.index]}';
    } catch (e) {
      print(
          'Could not initialize recording file location because of error = $e');
    }
  }

  //private properties
  FlutterSoundRecorder _recorder;
  StreamController<RecordingStatus> _streamController =
      StreamController<RecordingStatus>();
  String _pathOfRecording;
  t_CODEC _codec = t_CODEC.CODEC_AAC;
  //paths depending on which codec is chosen
  static const List<String> _fileExtensions = [
    '.aac', // DEFAULT
    '.aac', // CODEC_AAC
    '.opus', // CODEC_OPUS
    '.caf', // CODEC_CAF_OPUS
    '.mp3', // CODEC_MP3
    '.ogg', // CODEC_VORBIS
    '.pcm', // CODEC_PCM
  ];
}

enum RecordingStatus { initialized, recording, paused, stopped }
