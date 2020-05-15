import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';

class RecorderService {
  FlutterSoundRecorder _recorderModule;
  t_CODEC _codec = t_CODEC.CODEC_AAC;
  //paths depending on which codec is chosen
  static const List<String> _paths = [
    'voice_message_recording.aac', // DEFAULT
    'voice_message_recording.aac', // CODEC_AAC
    'voice_message_recording.opus', // CODEC_OPUS
    'voice_message_recording.caf', // CODEC_CAF_OPUS
    'voice_message_recording.mp3', // CODEC_MP3
    'voice_message_recording.ogg', // CODEC_VORBIS
    'voice_message_recording.pcm', // CODEC_PCM
  ];

  RecorderService() {
    _initializeRecorder();
  }

  _initializeRecorder() async {
    _recorderModule = await FlutterSoundRecorder().initialize();
    await _recorderModule.setDbPeakLevelUpdate(0.8);
    await _recorderModule.setDbLevelEnabled(true);
    await _recorderModule.setDbLevelEnabled(true);
  }

  releaseRecorder() async {
    try {
      await _recorderModule.release();
    } catch (e) {
      print('Could not release recorder because of error = $e');
    }
  }

  start() async {
    try {
      Directory tempDir = await getTemporaryDirectory();

      String path = await _recorderModule.startRecorder(
        uri:
            '${tempDir.path}/${_recorderModule.slotNo}-${_paths[_codec.index]}',
        codec: _codec,
      );
    } catch (e) {
      print("Could not start recording because of error = $e");
    }
  }

  pause() {
    try {
      _recorderModule.pauseRecorder();
    } catch (e) {
      print("Could not pause recording because of error = $e");
    }
  }

  resume() {
    try {
      _recorderModule.resumeRecorder();
    } catch (e) {
      print("Could not resume recording because of error = $e");
    }
  }

  stop() async {
    try {
      String result = await _recorderModule.stopRecorder();
    } catch (e) {
      print("Could not stop recorder because of error: $e");
    }
  }

  Stream<RecordStatus> getRecorderStatus() {
    try {
      return _recorderModule.onRecorderStateChanged;
    } catch (e) {
      print("Could not get recorder status because of error: $e");
      return null;
    }
  }
}
