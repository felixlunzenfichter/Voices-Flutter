import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/audio_chunk.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/models/user.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/shared%20widgets/time_stamp_text.dart';
import 'package:voices/services/recorder_service.dart';
import 'package:voices/services/player_service_single.dart';

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
  Stream<List<TextMessage>> messagesStream;

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
    return StreamBuilder<List<TextMessage>>(
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

        final List<TextMessage> messages = snapshot.data;

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
  final List<TextMessage> messages;

  ListOfMessages({@required this.messages});

  @override
  _ListOfMessagesState createState() => _ListOfMessagesState();
}

class _ListOfMessagesState extends State<ListOfMessages>
    with SingleTickerProviderStateMixin {
  List<TextMessage> _messages;
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
        TextMessage message = _messages[index];
        return MessageRow(
          message: message,
          isMe: screenInfo.loggedInUser.uid == message.senderUid,
        );
      },
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
    );
  }

  _insertMessageAtIndex({@required TextMessage message, @required int index}) {
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
        if (recorderService.currentStatus == RecordingStatus.Stopped)
          PlayerInfo(),
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
                  TextMessage message = TextMessage(
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
            if (recorderService.currentStatus == RecordingStatus.Unset ||
                recorderService.currentStatus == RecordingStatus.Stopped)
              StartRecordingButton(
                onPress: () async {
                  await recorderService.startRecording();
                },
              ),
            if (recorderService.currentStatus == RecordingStatus.Recording)
              PauseRecordingButton(
                onPress: () async {
                  await recorderService.pauseRecording();
                },
              ),
            if (recorderService.currentStatus == RecordingStatus.Paused)
              ResumeRecordingButton(
                onPress: () async {
                  await recorderService.resumeRecording();
                },
              ),
            if (recorderService.currentStatus == RecordingStatus.Recording ||
                recorderService.currentStatus == RecordingStatus.Paused)
              StopRecordingButton(
                onPress: () async {
                  await recorderService.stopRecording();
                  final playerService =
                      Provider.of<PlayerServiceSingle>(context, listen: false);
                  playerService.initializePlayer(
                      audioChunk: AudioChunk(
                          path: recorderService.currentRecording.path,
                          length: recorderService.currentRecording.duration));
                },
              ),
            if (!recorderService.isDirectSendActivated &&
                (recorderService.currentStatus == RecordingStatus.Recording ||
                    recorderService.currentStatus == RecordingStatus.Paused))
              ActivateDirectSendButton(
                onPress: () async {
                  recorderService.activateDirectSend();
                },
              ),
          ],
        ),
      ],
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

class StartRecordingButton extends StatelessWidget {
  final Function onPress;

  StartRecordingButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.mic,
    );
  }
}

class PauseRecordingButton extends StatelessWidget {
  final Function onPress;

  PauseRecordingButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.pause,
    );
  }
}

class ResumeRecordingButton extends StatelessWidget {
  final Function onPress;

  ResumeRecordingButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.play_arrow,
    );
  }
}

class StopRecordingButton extends StatelessWidget {
  final Function onPress;

  StopRecordingButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.stop,
    );
  }
}

class SpeedButton extends StatelessWidget {
  final Function onPress;
  final String text;

  SpeedButton({@required this.onPress, @required this.text});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(0),
      onPressed: onPress,
      child: Container(
        padding: EdgeInsets.all(9),
        decoration:
            ShapeDecoration(color: Colors.tealAccent, shape: CircleBorder()),
        child: Text(
          text,
        ),
      ),
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

class PlayButton extends StatelessWidget {
  final Function onPress;

  PlayButton({@required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPress: onPress,
      iconData: Icons.play_arrow,
    );
  }
}

class RecordingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recorderService = Provider.of<RecorderService>(context);
    switch (recorderService.currentStatus) {
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
              "recordingStatus = ${recorderService.currentStatus} is unknown");
        }
        break;
    }
  }
}

class PlayerInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayerServiceSingle>(context);
    print(playerService.currentStatus);
    return Container(
      color: Colors.yellow,
      height: 70,
      child: Row(
        children: <Widget>[
          if (playerService.currentStatus == PlayerStatus.playing)
            PauseButton(
              onPress: () {
                playerService.pause();
              },
            )
          else
            PlayButton(
              onPress: () async {
                await playerService.play();
              },
            ),
          SizedBox(
            width: 200,
            child: Consumer<PlayerServiceSingle>(
              builder: (context, playerService, child) {
                final Duration lengthOfAudio = playerService.audioChunk.length;
                final double progress =
                    playerService.currentPosition.inMilliseconds.toDouble() /
                        lengthOfAudio.inMilliseconds.toDouble();

                return LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  value: progress,
                );
              },
            ),
          ),
          if (playerService.currentStatus == PlayerStatus.playing ||
              playerService.currentStatus == PlayerStatus.paused)
            StopButton(
              onPress: () {
                playerService.stop();
              },
            ),
          SpeedButton(
            onPress: () {
              if (playerService.currentSpeed == 1) {
                playerService.setSpeed(speed: 2);
              } else {
                playerService.setSpeed(speed: 1);
              }
            },
            text: "${playerService.currentSpeed}x",
          ),
          Text("${playerService.currentPosition.inSeconds}s of"),
          Text("  ${playerService.audioChunk.length.inSeconds}s"),
        ],
      ),
    );
  }
}

class MessageRow extends StatelessWidget {
  MessageRow({this.message, this.isMe});

  final TextMessage message;
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
