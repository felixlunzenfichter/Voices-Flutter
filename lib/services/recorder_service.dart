import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/services/file_converter_service.dart';

/// This class provides and interface to [FlutterSoundRecorder].
class RecorderService with ChangeNotifier {
  /// Current recording.
  Recording _recording;

  /// Get Current recording.
  Recording get recording => _recording;

  /// Set Current recording.
  set recording(Recording recording) {
    _recording = recording;
    notifyListeners();
  }

  int getLength() async {
    int durationInMs = await flutterSoundHelper.duration(_pathToSavedRecording);
    return durationInMs;
  }

  RecordingStatus status = RecordingStatus.uninitialized;

  /// Constants.
  static const String RECORDING_FORMAT = ".aac";
  static const String LISTENING_FORMAT = ".mp3";
  static const Duration UPDATE_DURATION_OF_POSITION_STREAM =
      Duration(milliseconds: 100);
  static const Duration UPDATE_DURATION_OF_DB_LEVEL_STREAM =
      Duration(milliseconds: 100);

  RecorderService() {
    _initialize();
  }

  /// Private properties.

  FlutterSoundRecorder _recorder;

  /// Temporary directory to save the current recording in.
  Directory _tempDir;

  /// Access service to convert audio formats.
  FileConverterService _fileConverterService = FileConverterService();

  /// This is the file path where the [_recorder] writes its data. From the moment it gets assigned in [_initialize()] it stays fixed.
  String _pathToCurrentRecording;

  /// This is the file path to which the [_recording] will be saved to. It changes with every call of [_startWithoutReset()]
  String _pathToSavedRecording;

  /// This function can only be executed once per session else it crashes on iOS (because there is already an initialized recorder)
  /// So when we hot restart the app this makes it crash
  _initialize() async {
    try {
      _recorder = await FlutterSoundRecorder().initialize();
      await _recorder.setSubscriptionDuration(
          UPDATE_DURATION_OF_POSITION_STREAM.inMilliseconds.toDouble() /
              1000.0);
      await _recorder.setDbPeakLevelUpdate(
          UPDATE_DURATION_OF_DB_LEVEL_STREAM.inMilliseconds.toDouble() /
              1000.0);
      await _recorder.setDbLevelEnabled(true);
      _tempDir = await getTemporaryDirectory();
      _pathToSavedRecording =
          "${_tempDir.path}/current_recording$LISTENING_FORMAT";
      status = RecordingStatus.initialized;

      /// Allows controls to be shown.
      notifyListeners();
    } catch (e) {
      print(
          "Recorder service could not be initialized because of the following error: $e");
    }
  }

  @override
  dispose() async {
    try {
      await _recorder.release();
      super.dispose();
    } catch (e) {
      print("Recorder service could not be disposed because of error = $e");
    }
  }

  start() async {
    try {
      /// Reset current recording so the position stream doesn't add the time of the last recording to its position.
      recording = null;
      await _startWithoutReset();
    } catch (e) {
      print("Recorder service could not start recording because of error = $e");
    }
  }

  _startWithoutReset() async {
    _pathToCurrentRecording =
        "${_tempDir.path}/${_recorder.slotNo}-current_recording$RECORDING_FORMAT";
    await _recorder.startRecorder(
      uri: _pathToCurrentRecording,
      codec: t_CODEC.CODEC_AAC,
    );
    status = RecordingStatus.recording;
    notifyListeners();
  }

  resume() async {
    try {
      await _startWithoutReset();
    } catch (e) {
      print(
          "Recorder service could not resume recording because of error = $e");
    }
  }

  pause() async {
    try {
      await _recorder.stopRecorder();
      await _setRecording();
      status = RecordingStatus.paused;
      notifyListeners();
    } catch (e) {
      print("Recorder service could not pause recording because of error = $e");
    }
  }

  stop() async {
    try {
      await _recorder.stopRecorder();

      /// If the [status] is paused the recording was already set when the last [pause()] was executed and doesn't need to be set again.
      if (status != RecordingStatus.paused) {
        await _setRecording();
      }
      status = RecordingStatus.stopped;
      notifyListeners();
    } catch (e) {
      print("Recorder service could not stop recording because of error = $e");
    }
  }

  /// This function can only be called this after [_recorder.startRecorder()] is done.
  Stream<Duration> getPositionStream() {
    try {
      return _recorder.onRecorderStateChanged.map((state) {
        Duration lengthOfCurrentRecording =
            recording?.duration ?? Duration.zero;
        return lengthOfCurrentRecording +
            Duration(milliseconds: state?.currentPosition?.toInt() ?? 0);
      });
    } catch (e) {
      print(
          "Recorder service could not get the recorders position stream because of error = $e");
      return Stream.value(Duration.zero);
    }
  }

  /// Provide the a stream of volume measured in Db.
  Stream<double> getDbLevelStream() {
    try {
      return _recorder.onRecorderDbPeakChanged;
    } catch (e) {
      print(
          "Recorder service could not get the recorders dbLevel stream because of error = $e");
      return Stream.value(0.0);
    }
  }

  /// Concatenate the current recording with the new recording and save it as the current recording
  _setRecording() async {
    /// If the recording is null that means it is the first chunk of audio since [start] has been called and there is nothing to concatenate
    if (recording != null) {
      /// Since the concatenate function needs the input files to be in the same format the current recording needs to be converted into the listeningFormat first
      String pathToConvertedFile =
          "${_tempDir.path}/converted_recording$LISTENING_FORMAT";
      await _fileConverterService
          .convertFileFromRecordingToListeningFormatAndSaveUnter(
              file: File(_pathToCurrentRecording), toPath: pathToConvertedFile);
      File concatenatedFile = await _fileConverterService.concatenate(
          file1: File(_pathToSavedRecording),
          file2: File(pathToConvertedFile),
          newFilename: "concatenated$LISTENING_FORMAT");
      await _fileConverterService.copyFileTo(
          file: concatenatedFile, toPath: _pathToSavedRecording);
    } else {
      /// Copy the current recording to the saved recording and convert the file from the recordingFormat to the listeningFormat
      await _fileConverterService
          .convertFileFromRecordingToListeningFormatAndSaveUnter(
              file: File(_pathToCurrentRecording),
              toPath: _pathToSavedRecording);
    }
    int durationInMs = await flutterSoundHelper.duration(_pathToSavedRecording);
    recording = Recording(
        path: _pathToSavedRecording,
        duration: Duration(milliseconds: durationInMs));
  }

  /// Todo: remove this if not necessary.
//  /// Save the recording for this chat
//  saveRecordingOfChat(String chatId) {
//    localStorageService.saveCurrentRecording(
//        recording: recording);
//  }
}

enum RecordingStatus { uninitialized, initialized, recording, paused, stopped }
