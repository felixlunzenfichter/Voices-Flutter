import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';

class RecorderService with ChangeNotifier {
  bool hasPermission;
  RecordingStatus recordingStatus = RecordingStatus.Unset;
  Recording currentRecording;
  FlutterAudioRecorder _recorder;
  static final int _samplingFrequency =
      44100; //this is the industry standard for audio files

  startRecording(
      {FunctionThatTakesRecordingAsArgument
          whatToDoWithUnfinishedRecording}) async {
    await _initializeRecorder();
    if (hasPermission) {
      if (whatToDoWithUnfinishedRecording != null) {
        const tick = const Duration(
            milliseconds:
                15); //this timer updates the current recording therefore the time should be chosen however much we need it to be updated. If we are just tracking seconds we could let the timer tick less often than 15ms.
        Timer.periodic(tick, (Timer t) async {
          if (recordingStatus == RecordingStatus.Stopped) {
            t.cancel();
          }
          currentRecording = await _recorder.current(channel: 0);
          print("currentRecording duration = ${currentRecording.duration}");
          notifyListeners();
          whatToDoWithUnfinishedRecording(currentRecording);
        });
      }
      await _recorder.start();
      recordingStatus = RecordingStatus.Recording;
      notifyListeners();
    }
  }

  pauseRecording() async {
    await _recorder.pause();
    recordingStatus = RecordingStatus.Paused;
    notifyListeners();
  }

  resumeRecording() async {
    await _recorder.resume();
    recordingStatus = RecordingStatus.Recording;
    notifyListeners();
  }

  stopRecording() async {
    Recording result = await _recorder.stop();
    currentRecording = result;
    recordingStatus = RecordingStatus.Stopped;
    notifyListeners();
  }

  _initializeRecorder() async {
    hasPermission = await FlutterAudioRecorder.hasPermissions;
    String customPath = '/voices_';
    Directory appDocDirectory;
    if (Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
    customPath = appDocDirectory.path +
        customPath +
        DateTime.now().millisecondsSinceEpoch.toString();

    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.WAV, sampleRate: _samplingFrequency);
    await _recorder.initialized;
    recordingStatus = RecordingStatus.Initialized;
    notifyListeners();
  }
}

typedef FunctionThatTakesRecordingAsArgument = Function(Recording recording);
