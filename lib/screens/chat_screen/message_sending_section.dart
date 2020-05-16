import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/screens/chat_screen/chat_screen.dart';
import 'package:voices/screens/chat_screen/widgets.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/services/recorder_service.dart';

class MessageSendingSection extends StatefulWidget {
  @override
  _MessageSendingSectionState createState() => _MessageSendingSectionState();
}

class _MessageSendingSectionState extends State<MessageSendingSection> {
  final TextEditingController _messageTextController = TextEditingController();
  String _messageText = "";
  bool isInitialized = false;

  Stream<RecordingStatus> _recorderStatusStream;
  Stream<Duration> _recorderPositionStream;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  @override
  void dispose() {
    super.dispose();
    final recorderService =
        Provider.of<RecorderService>(context, listen: false);
    recorderService.dispose();
  }

  _initializeRecorder() async {
    final recorderService =
        Provider.of<RecorderService>(context, listen: false);
    await recorderService.initialize();
    setState(() {
      isInitialized = true;
    });
    _recorderStatusStream = recorderService.getRecorderStatusStream();
    _recorderPositionStream = recorderService.getRecorderPositionStream();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }
    final recorderService =
        Provider.of<RecorderService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final screenInfo =
        Provider.of<GlobalChatScreenInfo>(context, listen: false);

    return Column(
      children: <Widget>[
        RecordingInfo(
          recorderStatusStream: _recorderStatusStream,
          positionStream: _recorderPositionStream,
        ),
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
              )
            else
              RecorderControls(
                  recorderStatusStream: _recorderStatusStream,
                  start: () {
                    recorderService.start();
                  },
                  pause: () {
                    recorderService.pause();
                  },
                  resume: (recorderService.resume()),
                  stopAndSend: () async {
                    try {
                      //stop the recording
                      await recorderService.stop();

                      //send the voice message
//                      final storageService =
//                          Provider.of<StorageService>(context, listen: false);
//                      String pathInFirebaseStorage =
//                          "voice_messages/${screenInfo.chatId}/${DateTime.now().millisecondsSinceEpoch.toString()}.aac";
//                      String downloadUrl = await storageService.uploadAudioFile(
//                          firebasePath: pathInFirebaseStorage,
//                          audioFile: File(recorderService.recording.path));
//                      VoiceMessage voiceMessage = VoiceMessage(
//                          senderUid: authService.loggedInUser.uid,
//                          downloadUrl: downloadUrl,
//                          transcript: "This is the transcript",
//                          length: recorderService.recording.duration);
//
//                      final cloudFirestoreService =
//                          Provider.of<CloudFirestoreService>(context,
//                              listen: false);
//                      await cloudFirestoreService.addVoiceMessage(
//                          chatId: screenInfo.chatId,
//                          voiceMessage: voiceMessage);
                    } catch (e) {
                      print(
                          "Something went wrong when uploading voice message: $e");
                    }
                  }),
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
