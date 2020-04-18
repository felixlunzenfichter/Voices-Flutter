import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:file/local.dart';

class RecorderService {
  static final int samplingFrequency =
      44100; //this is the industry standard for audio files

  bool _hasPermission;
  FlutterAudioRecorder recorder;

  initialize() async {
    _hasPermission = await FlutterAudioRecorder.hasPermissions;
    recorder = FlutterAudioRecorder("file_path",
        audioFormat: AudioFormat.WAV, sampleRate: samplingFrequency);
    await recorder.initialized;
  }

  //takes a callback that is executed whenever a chunk is ready
  startRecording() async {
    if (_hasPermission) {
      await recorder.start();
    }
  }

  pauseRecording() async {
    await recorder.pause();
  }

  resumeRecording() async {
    await recorder.resume();
  }

  Future<AudioRecording> stopRecording() async {
    Recording result = await recorder.stop();
    LocalFileSystem localFileSystem = FlutterAudioRecorder.fs;
    File file = localFileSystem.file(result.path);
    AudioRecording audioRecording =
        AudioRecording(audioFile: file, length: result.duration);
    return audioRecording;
  }

//  static final int chunkTimeInSec = 2;
//  //takes a callback that is executed whenever a chunk is ready
//  startRecordingChunks({@required Function whatToDoWithChunk}) async {
//    //todo dynamically create recorders that are ready to start listening when the one before is finished
//    //have a recorder stop recording after 2 seconds and have another recorder start recording
//    await recorder.start();
//    Recording recording = await recorder.current(channel: 0);
//  }
//
//  pauseRecordingChunks() async {
//    //todo stop the recorder thats currently recording a chunk
//    await recorder.pause();
//  }
//
//  resumeRecordingChunks() async {
//    await recorder.resume();
//  }
//
//  stopRecordingChunks() async {
//    //todo stop recorder thats currently recording a chunk and return his last chunk
//    Recording result = await recorder.stop();
//    LocalFileSystem localFileSystem = FlutterAudioRecorder.fs;
//    File file = localFileSystem.file(result.path);
//  }
}

class AudioRecording {
  final File audioFile;
  final Duration length;

  AudioRecording({@required this.audioFile, @required this.length});
}
