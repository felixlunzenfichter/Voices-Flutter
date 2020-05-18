import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/services/file_converter_service.dart';

class RecorderService with ChangeNotifier {
  Recording recording;
  RecordingStatus status = RecordingStatus.uninitialized;

  RecorderService() {
    _initialize();
  }

  /// Private properties
  FlutterSoundRecorder _recorder;
  Directory _tempDir;
  FileConverterService _fileConverterService = FileConverterService();

  /// This is the file path in which the [_recorder] writes its data. From the moment it gets assigned in [_initialize()] it stays fixed
  String _pathToCurrentRecording;

  /// This is the file path to which the [recording] will be saved to. It changes with every call of [_startWithoutReset()]
  String _pathToSavedRecording;

  /// This function can only be executed once per session else it crashes on iOS (because there is already an initialized recorder)
  /// So when we hot restart the app this makes it crash
  _initialize() async {
    _recorder = await FlutterSoundRecorder().initialize();
    await _recorder.setSubscriptionDuration(0.01);
    await _recorder.setDbPeakLevelUpdate(0.8);
    await _recorder.setDbLevelEnabled(true);
    _tempDir = await getTemporaryDirectory();
    _pathToSavedRecording = "${_tempDir.path}/saved_recording.aac";
    status = RecordingStatus.initialized;
    notifyListeners();
  }

  @override
  dispose() async {
    await _recorder.release();
    super.dispose();
  }

  start() async {
    /// Reset current recording so the position stream doesn't add the time of the last recording to its position
    recording = null;

    /// Delete the last saved recording so new recordings are not concatenated to it
    /// Todo check if this is necessary
    _fileConverterService.deleteFileAt(path: _pathToSavedRecording);
    await _startWithoutReset();
  }

  stop() async {
    await _recorder.stopRecorder();

    /// If the [status] is paused the recording was already set when the last [pause()] was executed and doesn't need to be set again
    if (status != RecordingStatus.paused) {
      await _setRecording();
    }
    status = RecordingStatus.stopped;
    notifyListeners();
  }

  pause() async {
    await _recorder.stopRecorder();
    await _setRecording();
    status = RecordingStatus.paused;
    notifyListeners();
  }

  resume() async {
    await _startWithoutReset();
  }

  /// This function can only be called this after [_recorder.startRecorder()] is done.
  Stream<Duration> getPositionStream() {
    return _recorder.onRecorderStateChanged.map((state) {
      Duration lengthOfCurrentRecording = recording?.duration ?? Duration.zero;
      return lengthOfCurrentRecording +
          Duration(milliseconds: state?.currentPosition?.toInt() ?? 0);
    });
  }

  Stream<double> getDbLevelStream() {
    return _recorder.onRecorderDbPeakChanged;
  }

  /// Concatenate the current recording with the new recording and save it as the current recording
  _setRecording() async {
    /// If the recording is null that means it is the first chunk of audio since [start] has been called and there is nothing to concatenate
    if (recording != null) {
      File concatenatedFile = await _fileConverterService.concatenate(
          file1: File(_pathToSavedRecording),
          file2: File(_pathToCurrentRecording),
          newFilename: "concatenated");
      await _fileConverterService.copyFileTo(
          file: concatenatedFile, toPath: _pathToSavedRecording);
    } else {
      ///copy the current recording to the saved recording
      await _fileConverterService.copyFileTo(
          file: File(_pathToCurrentRecording), toPath: _pathToSavedRecording);
    }
    int durationInMs = await flutterSoundHelper.duration(_pathToSavedRecording);
    recording = Recording(
        path: _pathToSavedRecording,
        duration: Duration(milliseconds: durationInMs));
  }

  _startWithoutReset() async {
    _pathToCurrentRecording =
        '${_tempDir.path}/${_recorder.slotNo}-current_recording.aac';
    await _recorder.startRecorder(
      uri: _pathToCurrentRecording,
      codec: t_CODEC.CODEC_AAC,
    );
    status = RecordingStatus.recording;
    notifyListeners();
  }
}

enum RecordingStatus { uninitialized, initialized, recording, paused, stopped }
