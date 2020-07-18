import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:voices/constants.dart';
import 'package:voices/models/recording.dart';
import 'package:voices/models/voice_message.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/services/cloud_storage_service.dart';

/// This service manages the local storage.
/// There are three components we have to manager for each chat:
/// 1. The current recording of a chat.
/// 2. The current recording in the player.
/// 3. The voice messages in the chat.
/// Recall that a recording consists of an audio file and a length. We save both in separate files.

class LocalStorageService {
  /// Path of the directory in the local storage this app uses. It's a constant.
  static String kLocalDirectoryPath = kLocalPath;

  /// Naming conventions for the storage. Could be moved to constants.
  static const String currentRecordingDirectoryName = 'current_recording';
  static const String CurrentRecordingaudioFileName =
      'current_recording_audio_file.mp3';
  static const String lengthFileName = 'length.txt';
  final String currentRecordingOfChatFilePath;
  final String currentRecordingAudioLengthFilePath;

  final String voiceMessagesFolderName = 'voice_messages';

  static const String audioFilesFolderName = 'audio_files';

  /// This needs to be set in order to access the right folders.
  final String chatId;

  /// todo: remove this.
//  LocalStorageService({this.chatId}) {
//    setLocalPath();
//    currentRecordingOfChatFilePath =
//        '$_localDirectoryPath/$chatId/$currentRecordingDirectoryName/$audioFileName';
//    audioLengthFilePath =
//        '$_localDirectoryPath/$chatId/$currentRecordingDirectoryName/$lengthFileName';
//  }

  LocalStorageService._(
      {this.chatId,
      this.currentRecordingOfChatFilePath,
      this.currentRecordingAudioLengthFilePath});

  factory LocalStorageService({String chatId}) {
    setLocalPath();
    String currentRecordingOfChatFilePath =
        '$kLocalDirectoryPath/$chatId/$currentRecordingDirectoryName/$CurrentRecordingaudioFileName';
    String audioLengthFilePath =
        '$kLocalDirectoryPath/$chatId/$currentRecordingDirectoryName/$lengthFileName';
    return LocalStorageService._(
      chatId: chatId,
      currentRecordingOfChatFilePath: currentRecordingOfChatFilePath,
      currentRecordingAudioLengthFilePath: audioLengthFilePath,
    );
  }

  static void setLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    kLocalDirectoryPath = directory.path;
  }

  /// Save the [recording] object in Files synchronously.
  Future<void> saveCurrentRecording({Recording recording}) async {
    /// Go to the right directory.

    /// Todo: How does .create() behave when the directory already exists?
    Directory directory = await Directory(
            '$kLocalDirectoryPath/$chatId/$currentRecordingDirectoryName')
        .create(recursive: true);
    File currentRecordingInRecorderFile = File(recording.path);
    File currentAudioRecordingOfChatFile = File(currentRecordingOfChatFilePath);
    File audioLengthFile = File(currentRecordingAudioLengthFilePath);
    await currentAudioRecordingOfChatFile.create();
    await audioLengthFile.create();
    currentAudioRecordingOfChatFile
        .writeAsBytesSync(currentRecordingInRecorderFile.readAsBytesSync());
    audioLengthFile
        .writeAsStringSync(recording.duration.inMilliseconds.toString());
    print('done saving');
  }

  /// Retrieve the current recording of the chat with UID [chatId] from local storage.
  Recording getCurrentRecording() {
    File audioLengthFile = File(currentRecordingAudioLengthFilePath);
    Recording recording = Recording(
        path: currentRecordingOfChatFilePath,
        duration: Duration(
            milliseconds: int.parse(audioLengthFile.readAsStringSync())));
    return recording;
  }

  Future<void> saveCurrentListening() async {}

  Future<Recording> getCurrentListening() async {}

  /*                    todo: implement this.
  Future<void> saveRecording({Recording recording, VoiceMessage voiceMessage}) {
    String voiceMessageId = voiceMessage.messageId;
    String voiceMessagePath =
        '$localDirectory/$chatId/$voiceMessagesFolderName/$voiceMessageId';
    File audio = File(voiceMessagePath);
  }

   */

  Future<Recording> getRecording({VoiceMessage voiceMessage}) async {
    String voiceMessageId = voiceMessage.messageId;
    String voiceMessagePath =
        '$kLocalDirectoryPath/$chatId/$voiceMessagesFolderName/$voiceMessageId.mp3';

    Directory directory =
        await Directory('$kLocalDirectoryPath/$chatId/$voiceMessagesFolderName')
            .create(recursive: true);

    if (!await File(voiceMessagePath).exists()) {
      File audio = File(voiceMessagePath);
      CloudStorageService cloudStorageService = CloudStorageService();
      File newAudio = await cloudStorageService.downloadAudioFile(
          voiceMessage: voiceMessage);
      audio.writeAsBytes(newAudio.readAsBytesSync());
      print('download');
    }
    File audio = File(voiceMessagePath);
    return Recording(path: audio.path, duration: Duration(seconds: 69));
  }
}
