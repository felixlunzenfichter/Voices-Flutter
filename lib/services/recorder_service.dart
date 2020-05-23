import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/services/file_converter_service.dart';

class RecorderService with ChangeNotifier {
  Recording recording;
  RecordingStatus status = RecordingStatus.uninitialized;
  static const String RECORDING_FORMAT = ".aac";
  static const String LISTENING_FORMAT = ".mp3";
  static const Duration UPDATE_DURATION_OF_STREAM = Duration(milliseconds: 100);

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
    try {
      /// The arguments for [openAudioSession] are explained here: https://github.com/dooboolab/flutter_sound/blob/master/doc/player.md#openaudiosession-and-closeaudiosession
      _recorder = await FlutterSoundRecorder().openAudioSession(
          focus: AudioFocus.requestFocusAndKeepOthers,
          category: SessionCategory.playAndRecord,
          mode: SessionMode.modeDefault,
          audioFlags: outputToSpeaker);
      await _recorder.setSubscriptionDuration(UPDATE_DURATION_OF_STREAM);
      _tempDir = await getTemporaryDirectory();
      _pathToSavedRecording =
          "${_tempDir.path}/saved_recording$LISTENING_FORMAT";
      status = RecordingStatus.initialized;
      notifyListeners();
    } catch (e) {
      print("Recorder service could not be initialized because of error = $e");
    }
  }

  @override
  dispose() async {
    try {
      await _recorder?.closeAudioSession();
      super.dispose();
    } catch (e) {
      print("Recorder service could not be disposed because of error = $e");
    }
  }

  /// The counters in this class ensure that the functions can only be executed once
  int _startCounter = 0;
  start() async {
    if (_startCounter == 0) {
      _startCounter++;
      try {
        /// Reset current recording so the position stream doesn't add the time of the last recording to its position
        recording = null;
        await _startWithoutReset();
      } catch (e) {
        print(
            "Recorder service could not start recording because of error = $e");
      }
      _startCounter = 0;
    }
  }

  int _stopCounter = 0;
  stop() async {
    if (_stopCounter == 0) {
      _stopCounter++;
      try {
        await _recorder.stopRecorder();

        /// If the [status] is paused the recording was already set when the last [pause()] was executed and doesn't need to be set again
        if (status != RecordingStatus.paused) {
          await _setRecording();
        }
        status = RecordingStatus.stopped;
        notifyListeners();
      } catch (e) {
        print(
            "Recorder service could not stop recording because of error = $e");
      }
      _stopCounter = 0;
    }
  }

  int _pauseCounter = 0;
  pause() async {
    if (_pauseCounter == 0) {
      _pauseCounter++;
      try {
        await _recorder.stopRecorder();
        await _setRecording();
        status = RecordingStatus.paused;
        notifyListeners();
      } catch (e) {
        print(
            "Recorder service could not pause recording because of error = $e");
      }
      _pauseCounter = 0;
    }
  }

  int _resumeCounter = 0;
  resume() async {
    if (_resumeCounter == 0) {
      _resumeCounter++;
      try {
        await _startWithoutReset();
      } catch (e) {
        print(
            "Recorder service could not resume recording because of error = $e");
      }
      _resumeCounter = 0;
    }
  }

  /// This function can probably (need to check) only be called this after [_recorder.startRecorder()] is done.
  Stream<RecordingDisposition> getProgressStream() {
    try {
      return _recorder.onProgress;
    } catch (e) {
      print(
          "Recorder service could not get the recorders position stream because of error = $e");
      return Stream.error("Could not get progress stream of recorder");
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
    Duration durationOfRecording =
        await flutterSoundHelper.duration(_pathToSavedRecording);
    recording =
        Recording(path: _pathToSavedRecording, duration: durationOfRecording);
  }

  _startWithoutReset() async {
    _pathToCurrentRecording =
        "${_tempDir.path}/${_recorder.slotNo}-current_recording$RECORDING_FORMAT";
    await _recorder.startRecorder(
      codec: Codec.defaultCodec,
      toFile: _pathToCurrentRecording,
      sampleRate: 16000,
      numChannels: 1,
      bitRate: 16000,
      audioSource: AudioSource.defaultSource,
    );
    status = RecordingStatus.recording;
    notifyListeners();
  }
}

enum RecordingStatus { uninitialized, initialized, recording, paused, stopped }
