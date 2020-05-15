import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/models/voice_message.dart';
import 'package:voices/screens/chat_screen/chat_screen.dart';
import 'package:voices/screens/chat_screen/widgets.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/services/recorder_service.dart';
import 'package:voices/services/speech_to_text_service.dart';
import 'package:voices/services/storage_service.dart';

class MessageSendingSection extends StatefulWidget {
  @override
  _MessageSendingSectionState createState() => _MessageSendingSectionState();
}

class _MessageSendingSectionState extends State<MessageSendingSection> {
  final TextEditingController _messageTextController = TextEditingController();
  String _messageText = "";

  @override
  Widget build(BuildContext context) {
    final recorderService =
        Provider.of<RecorderService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final SpeechToTextService speechToText =
        Provider.of<SpeechToTextService>(context);
    final screenInfo =
        Provider.of<GlobalChatScreenInfo>(context, listen: false);

    return Column(
      children: <Widget>[
        RecordingInfo(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: SendTextField(
                    controller: _messageTextController,
                    onTextChanged: _onTextChanged)),
            if (_messageText != "")
              SendTextButton(
                onPress: () async {
                  // prevent to send the previously typed message with an empty text field
                  //Implement send functionality.
                  TextMessage message = TextMessage(
                      senderUid: authService.loggedInUser.uid,
                      text: _messageText);
                  final cloudFirestoreService =
                      Provider.of<CloudFirestoreService>(context,
                          listen: false);
                  cloudFirestoreService.addTextMessage(
                      chatId: screenInfo.chatId, textMessage: message);
                  //clear text field
                  _messageTextController.text = "";
                },
              ),
            if (recorderService.currentStatus == RecordingStatus.Unset ||
                recorderService.currentStatus == RecordingStatus.Stopped)
              StartRecordingButton(
                onPress: () async {
                  // Speech to text converter
                  speechToText.start();
                  await recorderService.startRecording();
                },
              ),
            if (recorderService.currentStatus == RecordingStatus.Recording)
              PauseRecordingButton(
                onPress: () async {
                  // pause speech to text.

                  await recorderService.pauseRecording();
                  speechToText.pause();
                },
              ),
            if (recorderService.currentStatus == RecordingStatus.Paused)
              ResumeRecordingButton(
                onPress: () async {
                  await recorderService.resumeRecording();
                  speechToText.start();
                },
              ),
            if (recorderService.currentStatus == RecordingStatus.Recording ||
                recorderService.currentStatus == RecordingStatus.Paused)
              StopRecordingButton(
                onPress: () async {
                  // Stop voice to text conversion service.
                  speechToText.stop();
                  try {
                    await recorderService.stopRecording();
                    final storageService =
                        Provider.of<StorageService>(context, listen: false);
                    String path =
                        "voice_messages/${screenInfo.chatId}/${DateTime.now().millisecondsSinceEpoch.toString()}.aac";
                    String downloadUrl = await storageService.uploadAudioFile(
                        firebasePath: path,
                        audioFile: File(recorderService.currentRecording.path));
                    VoiceMessage voiceMessage = VoiceMessage(
                        senderUid: authService.loggedInUser.uid,
                        downloadUrl: downloadUrl,
                        transcript: "This is the transcript",
                        length: recorderService.currentRecording.duration);

                    final cloudFirestoreService =
                        Provider.of<CloudFirestoreService>(context,
                            listen: false);
                    await cloudFirestoreService.addVoiceMessage(
                        chatId: screenInfo.chatId, voiceMessage: voiceMessage);
                  } catch (e) {
                    print(
                        "Something went wrong when uploading voice message: $e");
                  }
//                  final playerService =
//                      Provider.of<PlayerService>(context, listen: false);
//                  playerService.initializePlayer(
//                      //audiochunk is the object used to pass information from recording to player
//                      audioChunk: AudioChunk(
//                          path: recorderService.currentRecording.path,
//                          length: recorderService.currentRecording.duration));
                },
              ),
          ],
        ),
      ],
    );
  }

  _onTextChanged(String newText) {
    setState(() {
      _messageText = newText;
    });
  }
}
