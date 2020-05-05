import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/audio_chunk.dart';
import 'package:voices/models/message.dart';
import 'package:voices/models/user.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/shared%20widgets/time_stamp_text.dart';
import 'package:voices/services/recorder_service.dart';
import 'package:voices/services/player_service.dart';
import 'package:voices/services/file_converter_service.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final User loggedInUser;
  final User otherUser;

  ChatScreen({
    @required this.chatId,
    @required
        this.loggedInUser, //is needed because this screen can't access it with provider TODO: What's provider? something to do with state management?
    @required this.otherUser,
  });

  // TODO: What does this do exactly?
  @override
  Widget build(BuildContext context) {
    return Provider<GlobalChatScreenInfo>(
      create: (_) => GlobalChatScreenInfo(
        chatId: chatId,
        loggedInUser: loggedInUser,
        otherUser: otherUser,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(otherUser.username),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: MessagesStream(),
              ),
              MessageSendingSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesStream extends StatefulWidget {
  @override
  _MessagesStreamState createState() => _MessagesStreamState();
}

class _MessagesStreamState extends State<MessagesStream> {
  Stream<List<Message>> messagesStream;

  @override
  void initState() {
    super.initState();
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    GlobalChatScreenInfo screenInfo =
        Provider.of<GlobalChatScreenInfo>(context, listen: false);
    messagesStream =
        cloudFirestoreService.getMessageStream(chatId: screenInfo.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none) {
          return CupertinoActivityIndicator();
        }

        if (snapshot.hasError) {
          return Container(
            color: Colors.red,
            child: Text(snapshot.error.toString()),
          );
        }

        final List<Message> messages = snapshot.data;

        if (messages == null) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Text(
                "There are no messages yet",
              ),
            ),
          );
        }
        return ListOfMessages(
          messages: messages,
        );
      },
    );
  }
}

class ListOfMessages extends StatefulWidget {
  final List<Message> messages;

  ListOfMessages({@required this.messages});

  @override
  _ListOfMessagesState createState() => _ListOfMessagesState();
}

class _ListOfMessagesState extends State<ListOfMessages>
    with SingleTickerProviderStateMixin {
  List<Message> _messages;
  final _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
  }

  @override
  void didUpdateWidget(ListOfMessages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages.length < widget.messages.length) {
      for (int i = 0;
          i < widget.messages.length - oldWidget.messages.length;
          i++) {
        _insertMessageAtIndex(message: widget.messages[i], index: i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalChatScreenInfo screenInfo =
        Provider.of<GlobalChatScreenInfo>(context, listen: false);
    return AnimatedList(
      key: _listKey,
      initialItemCount: _messages.length,
      itemBuilder: (context, index, animation) {
        Message message = _messages[index];
        return MessageRow(
          message: message,
          isMe: screenInfo.loggedInUser.uid == message.senderUid,
        );
      },
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
    );
  }

  _insertMessageAtIndex({@required Message message, @required int index}) {
    _messages.insert(index, message);
    _listKey.currentState.insertItem(index);
  }
}

class MessageSendingSection extends StatefulWidget {
  @override
  _MessageSendingSectionState createState() => _MessageSendingSectionState();
}

class _MessageSendingSectionState extends State<MessageSendingSection> {
  String _messageText = "";

  @override
  Widget build(BuildContext context) {
    final recorderService = Provider.of<RecorderService>(context);
    return Column(
      children: <Widget>[
        RecordingInfo(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: CupertinoTextField(
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: false,
                  maxLength: 200,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  placeholder: "Enter message",
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                  ),
                  onChanged: (newMessage) {
                    setState(() {
                      _messageText = newMessage;
                    });
                  },
                ),
              ),
            ),
            if (_messageText != "")
              SendTextButton(
                onPress: () async {
                  // prevent to send the previously typed message with an empty text field
                  //Implement send functionality.
                  GlobalChatScreenInfo screenInfo =
                      Provider.of<GlobalChatScreenInfo>(context, listen: false);
                  Message message = Message(
                      senderUid: screenInfo.loggedInUser.uid,
                      text: _messageText);
                  final cloudFirestoreService =
                      Provider.of<CloudFirestoreService>(context,
                          listen: false);
                  cloudFirestoreService.addMessage(
                      chatId: screenInfo.chatId, message: message);
                  setState(() {
                    _messageText = "";
                  });
                },
              ),
            if (recorderService.recordingStatus == RecordingStatus.Unset ||
                recorderService.recordingStatus == RecordingStatus.Stopped)
              StartButton(
                onPress: () async {
                  await recorderService.startRecording();
                },
              ),
            if (recorderService.recordingStatus == RecordingStatus.Recording)
              PauseButton(
                onPress: () async {
                  await recorderService.pauseRecording();
                },
              ),
            if (recorderService.recordingStatus == RecordingStatus.Paused)
              ResumeButton(
                onPress: () async {
                  await recorderService.resumeRecording();
                },
              ),
            if (recorderService.recordingStatus == RecordingStatus.Recording ||
                recorderService.recordingStatus == RecordingStatus.Paused)
              StopButton(
                onPress: () async {
                  await recorderService.stopRecording();
                },
              ),
            if (!recorderService.isDirectSendActivated &&
                (recorderService.recordingStatus == RecordingStatus.Recording ||
                    recorderService.recordingStatus == RecordingStatus.Paused))
              ActivateDirectSendButton(
                onPress: () async {
                  recorderService.activateDirectSend();
                },
              ),
            if (recorderService.recordingStatus == RecordingStatus.Stopped)
              ListenToRecordingButton(
                onPress: () async {
                  final playerService =
                      Provider.of<PlayerService>(context, listen: false);
                  playerService.audioChunks = [];
                  for (Recording recordingChunk
                      in recorderService.currentRecordingChunks) {
                    AudioChunk chunk = AudioChunk(
                        path: recordingChunk.path,
                        length: recordingChunk.duration);
                    playerService.appendChunk(audioChunk: chunk);
                  }
                  await playerService.play();
                },
              ),
            if (recorderService.recordingStatus == RecordingStatus.Stopped)
              ConcatenateButton(
                onPress: () async {
                  final fileService =
                      Provider.of<FileConverterService>(context, listen: false);
                  File file1 =
                      File(recorderService.currentRecordingChunks[0].path);
                  File file2 =
                      File(recorderService.currentRecordingChunks[1].path);
                  File concatenatedFile =
                      await fileService.appendChunkToFileAndSave(
                          file: file1, chunk: file2, newFilename: "soup");
                  await concatenatedFile.copy(file1.path);
                },
              )
          ],
        ),
      ],
    );
  }
}

class RecordingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recorderService = Provider.of<RecorderService>(context);
    switch (recorderService.recordingStatus) {
      case RecordingStatus.Unset:
        {
          return Text("Ready to record");
        }
        break;
      case RecordingStatus.Initialized:
        {
          return Text("Recorder is initialized");
        }
        break;
      case RecordingStatus.Recording:
        {
          return Text(
              "Is recording: ${recorderService.currentRecording?.duration?.inSeconds.toString()}s");
        }
        break;

      case RecordingStatus.Paused:
        {
          return Text(
              "Is paused: ${recorderService.currentRecording?.duration?.inSeconds.toString()}s");
        }
        break;

      case RecordingStatus.Stopped:
        {
          return Text(
              "Recording saved under ${recorderService.currentRecording?.path}");
        }
        break;

      default:
        {
          return Text(
              "recordingStatus = ${recorderService.recordingStatus} is unknown");
        }
        break;
    }
  }
}

class MessageRow extends StatelessWidget {
  MessageRow({this.message, this.isMe});

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
      child: Column(
        // a column with just one child because I haven't figure out out else to size the bubble to fit its contents instead of filling it
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          MessageBubble(
              isMe: isMe, text: message.text, timestamp: message.timestamp),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key key,
    @required this.isMe,
    @required this.text,
    @required this.timestamp,
  }) : super(key: key);

  final bool isMe;
  final String text;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: isMe
          ? BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15))
          : BorderRadius.only(
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15)),
      elevation: 0.0,
      color: isMe ? Colors.yellow : Colors.teal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            TimeStampText(timestamp: timestamp)
          ],
        ),
      ),
    );
  }
}

class SendTextButton extends StatelessWidget {
  final Function onPress;

  SendTextButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.send,
    );
  }
}

class StartButton extends StatelessWidget {
  final Function onPress;

  StartButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.mic,
    );
  }
}

class PauseButton extends StatelessWidget {
  final Function onPress;

  PauseButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.pause,
    );
  }
}

class ResumeButton extends StatelessWidget {
  final Function onPress;

  ResumeButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.play_arrow,
    );
  }
}

class StopButton extends StatelessWidget {
  final Function onPress;

  StopButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.stop,
    );
  }
}

class ConcatenateButton extends StatelessWidget {
  final Function onPress;

  ConcatenateButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.control_point,
    );
  }
}

class ActivateDirectSendButton extends StatelessWidget {
  final Function onPress;

  ActivateDirectSendButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.all_out,
    );
  }
}

class ListenToRecordingButton extends StatelessWidget {
  final Function onPress;

  ListenToRecordingButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.play_arrow,
    );
  }
}

class RoundButton extends StatelessWidget {
  final Function onPress;
  final IconData iconData;

  RoundButton({@required this.iconData, @required this.onPress});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(0),
      onPressed: onPress,
      child: Container(
        padding: EdgeInsets.all(9),
        decoration:
            ShapeDecoration(color: Colors.tealAccent, shape: CircleBorder()),
        child: Icon(
          iconData,
          color: Colors.brown,
          size: 22,
        ),
      ),
    );
  }
}

class GlobalChatScreenInfo {
  final String chatId;
  final User loggedInUser;
  final User otherUser;

  GlobalChatScreenInfo({
    @required this.chatId,
    @required this.loggedInUser,
    @required this.otherUser,
  });
}
