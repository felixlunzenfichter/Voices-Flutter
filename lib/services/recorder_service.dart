import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voices/services/file_converter_service.dart';

class RecorderService with ChangeNotifier {
  //publicly available
  Recording
      currentRecording; //while recording the outside has access to the current recording with this property
  List<Recording> currentRecordingChunks =
      []; //if direct send is enabled chunks of the recording are saved in this list
  bool hasPermission = false;
  bool isDirectSendActivated = false;
  RecordingStatus currentStatus = RecordingStatus.Unset;
  static const Duration DEFAULT_CHUNK_SIZE =
      Duration(seconds: 3); //the last chunk might have a different size
  static const int SAMPLING_FREQUENCY =
      44100; //this is the industry standard for audio files (44100 samples per second)

  //for internal use only
  FlutterAudioRecorder _recorder;
  Duration _howMuchOfCurrentMessageSent = Duration(milliseconds: 0);
  final FileConverterService _fileConverterService = FileConverterService();

  activateDirectSend() {
    isDirectSendActivated = true;
    notifyListeners();
  }

  startRecording() async {
    await _initializeRecorder();

    if (hasPermission) {
      const tickToUpdateUI = const Duration(
          milliseconds:
              15); //this timer updates the current recording therefore the time should be chosen however much we need it to be updated. If we are just tracking seconds we could let the timer tick less often than 15ms.
      Timer.periodic(tickToUpdateUI, (Timer t) async {
        if (currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }
        currentRecording = await _recorder.current(channel: 0);
        notifyListeners();
      });

      //this timer adds chunks to the list of chunks if direct send is activated
      Timer.periodic(DEFAULT_CHUNK_SIZE, (Timer t) async {
        if (currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }
        if (isDirectSendActivated) {
          _addChunkToListOfChunks();
        }
      });

      await _recorder.start();
      _howMuchOfCurrentMessageSent = Duration(milliseconds: 0);
      currentRecordingChunks = [];
      currentRecording = null;
      currentStatus = RecordingStatus.Recording;
      notifyListeners();
    }
  }

  pauseRecording() async {
    currentStatus = RecordingStatus.Paused;
    notifyListeners();
    await _recorder.pause();
  }

  resumeRecording() async {
    currentStatus = RecordingStatus.Recording;
    notifyListeners();
    await _recorder.resume();
  }

  stopRecording() async {
    isDirectSendActivated = false;
    currentStatus = RecordingStatus.Stopped;
    notifyListeners();
    Recording result = await _recorder.stop();
    if (isDirectSendActivated) {
      _addLastChunk();
    } else {
      currentRecording = result;
    }
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
        audioFormat: AudioFormat.AAC, sampleRate: SAMPLING_FREQUENCY);
    await _recorder.initialized;
    currentStatus = RecordingStatus.Initialized;
    notifyListeners();
  }

  _addChunkToListOfChunks() async {
    //check if a new chunk is ready to be processed
    Duration currentRecordingLength = currentRecording.duration;
    bool isNewChunkReady = currentRecordingLength >
        _howMuchOfCurrentMessageSent + DEFAULT_CHUNK_SIZE;
    if (isNewChunkReady) {
      Duration startTimeOfChunk = _howMuchOfCurrentMessageSent;
      Duration endTimeOfChunk = startTimeOfChunk + DEFAULT_CHUNK_SIZE;
      assert(endTimeOfChunk < currentRecordingLength);
      _getChunkAndAddToChunkList(
          startTime: startTimeOfChunk, endTime: endTimeOfChunk);
    }
  }

  _addLastChunk() async {
    Duration startTimeOfChunk = _howMuchOfCurrentMessageSent;
    Duration endTimeOfChunk = currentRecording.duration;
    _getChunkAndAddToChunkList(
        startTime: startTimeOfChunk, endTime: endTimeOfChunk);
  }

  _getChunkAndAddToChunkList(
      {@required Duration startTime, @required Duration endTime}) async {
    //get the audio chunk
    File chunk = await _fileConverterService.createAudioFileChunkFromFile(
        file: File(currentRecording.path),
        startTime: startTime,
        endTime: endTime,
        chunkFilename: currentRecordingChunks.length.toString());

    //create recording and add it to the list of recordings
    Recording recordingChunk = Recording();
    recordingChunk.path = chunk.path;
    recordingChunk.extension = currentRecording.extension;
    recordingChunk.duration = endTime - startTime;
    recordingChunk.audioFormat = AudioFormat.AAC;
    recordingChunk.metering = currentRecording.metering;
    recordingChunk.status = RecordingStatus.Stopped;
    currentRecordingChunks.add(recordingChunk);

    _howMuchOfCurrentMessageSent = endTime;
  }
}
