import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/models/chat.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/shared%20widgets/profile_picture.dart';
import 'chat_screen.dart';

class ChatsTab extends StatefulWidget {
  @override
  _ChatsTabState createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  Stream<List<Chat>> chatStream;

  @override
  void initState() {
    super.initState();
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    final loggedInUser = Provider.of<User>(context, listen: false);
    chatStream =
        cloudFirestoreService.getChatsStream(loggedInUid: loggedInUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Chats"),
        trailing: CupertinoButton(
          child: Icon(Icons.add_circle_outline),
          onPressed: () {
            //todo open new chat
          },
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                child: StreamBuilder(
                    stream: chatStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.none) {
                        return CupertinoActivityIndicator();
                      }
                      List<Chat> chats = List.from(
                          snapshot.data); // to convert it to editable list
                      chats.sort((chat1, chat2) => (chat2.lastMessageTimestamp)
                          .compareTo(chat1.lastMessageTimestamp));

                      if (chats.isEmpty) {
                        return Center(child: Text("You have no open chats"));
                      }
                      return ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            return ChatItem(
                              chat: chats[index],
                            );
                          });
                    }))
          ],
        ),
      ),
    );
  }
}

class ChatItem extends StatefulWidget {
  final Chat chat;

  ChatItem({@required this.chat});

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  Future<User> otherUserFuture;

  @override
  void initState() {
    super.initState();
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    final loggedInUser = Provider.of<User>(context, listen: false);
    String otherUserUid = widget.chat.uidsOfMembers
        .where((uid) => uid != loggedInUser.uid)
        .toList()[0];
    otherUserFuture = cloudFirestoreService.getUser(uid: otherUserUid);
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<User>(context);

    return FutureBuilder(
      future: otherUserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CupertinoActivityIndicator();
        }
        if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.red,
              child: Text(
                "Error occured: ${snapshot.error}",
              ),
            ),
          );
        }
        User otherUser = snapshot.data;
        return CustomCard(
          leading: ProfilePicture(imageUrl: otherUser.imageUrl, radius: 30),
          middle: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    otherUser.username,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(
                    child: Text(
                      widget.chat.lastMessageTimestamp,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.chat.lastMessageText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          onPress: () async {
            await Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute<void>(
                builder: (context) {
                  return ChatScreen(
                    chatId: widget.chat.chatId,
                    loggedInUser: loggedInUser,
                    otherUser: otherUser,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class CustomCard extends StatelessWidget {
  final Widget leading;
  final Widget middle;
  final Function onPress;
  final Function onLongPress;
  final double paddingInsideHorizontal;
  final double paddingInsideVertical;

  CustomCard(
      {@required this.leading,
      @required this.middle,
      @required this.onPress,
      this.onLongPress,
      this.paddingInsideHorizontal = 15,
      this.paddingInsideVertical = 10});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: GestureDetector(
        onTap: onPress,
        onLongPress: onLongPress,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: paddingInsideHorizontal,
              vertical: paddingInsideVertical),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.lightBlueAccent,
          ),
          child: Row(
            children: <Widget>[
              leading,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: middle,
                ),
              ),
              Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
