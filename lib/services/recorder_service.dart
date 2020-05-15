import 'dart:async';
import 'dart:io';
import 'package:voices/models/recording.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';

class RecorderService {
  Recording recording;

  //private properties
  FlutterSoundRecorder _recorderModule;
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

  RecorderService() {
    _initializeRecorder();
    _initializeFileLocation();
    _streamController.add(RecordingStatus.initialized);
  }

  _initializeRecorder() async {
    _recorderModule = await FlutterSoundRecorder().initialize();
    await _recorderModule.setDbPeakLevelUpdate(0.8);
    await _recorderModule.setDbLevelEnabled(true);
    await _recorderModule.setDbLevelEnabled(true);
  }

  _initializeFileLocation() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      _pathOfRecording =
          '${tempDir.path}/${_recorderModule.slotNo}-voice_message_recording${_fileExtensions[_codec.index]}';
    } catch (e) {
      print(
          'Could not initialize recording file location because of error = $e');
    }
  }

  disposeRecorder() async {
    try {
      await _recorderModule.release();
      await _streamController.close();
    } catch (e) {
      print('Could not release recorder because of error = $e');
    }
  }

  start() async {
    try {
      _streamController.add(RecordingStatus.recording);
      await _recorderModule.startRecorder(
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
      _recorderModule.pauseRecorder();
    } catch (e) {
      print("Could not pause recording because of error = $e");
    }
  }

  resume() {
    try {
      _streamController.add(RecordingStatus.recording);
      _recorderModule.resumeRecorder();
    } catch (e) {
      print("Could not resume recording because of error = $e");
    }
  }

  stop() async {
    try {
      _streamController.add(RecordingStatus.stopped);
      await _recorderModule.stopRecorder();
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
      return _recorderModule.onRecorderStateChanged.map(
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
}

enum RecordingStatus { initialized, recording, paused, stopped }
