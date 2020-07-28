import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/voice_message.dart';
import 'package:voices/screens/conversation_screen/conversation_screen.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/services/recorder_service.dart';
import 'package:voices/services/cloud_storage_service.dart';
import 'package:voices/services/logged_in_user_service.dart';
import 'dart:io';

/// Send a voice message.
dynamic sendvm({BuildContext context}) async {
  /// Access Services.
  RecorderService recorderService =
      Provider.of<RecorderService>(context, listen: false);
  CloudFirestoreService cloudFirestoreServiced =
      Provider.of<CloudFirestoreService>(context, listen: false);
  GlobalChatScreenState screenInfo =
      Provider.of<GlobalChatScreenState>(context, listen: false);
  LoggedInUserService authService =
      Provider.of<LoggedInUserService>(context, listen: false);
  CloudStorageService storageService =
      Provider.of<CloudStorageService>(context, listen: false);

  /// Store Audio file in the cloud.

  DateTime timestamp = DateTime.now();

  String firebasePath =
      'voice_messages/${screenInfo.chatId}/${timestamp.toString()}';

  String downloadURL = await storageService.uploadAudioFile(
      firebasePath: firebasePath,
      audioFile: File(recorderService.recording.path));

  VoiceMessage voiceMessage = VoiceMessage(
      senderUid: authService.loggedInUser.uid,
      timestamp: timestamp,
      downloadUrl: downloadURL,
      transcript: 'transcript',
      length: recorderService.recording.duration,
      firebasePath: firebasePath);

  cloudFirestoreServiced.addVoiceMessage(
      chatId: screenInfo.chatId, voiceMessage: voiceMessage);

  print(
      'uploaded ${recorderService.recording.path} to cloud storage in location ${voiceMessage.firebasePath}');
}
