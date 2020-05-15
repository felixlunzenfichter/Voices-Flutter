import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/models/chat.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';
//import 'package:voices/shared_widgets/profile_picture.dart';
import 'chat_screen/chat_screen.dart';
import 'search_users_screen.dart';
import 'package:voices/shared_widgets/custom_card.dart';

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
    final authService = Provider.of<AuthService>(context, listen: false);
    chatStream = cloudFirestoreService.getChatsStream(
        loggedInUid: authService.loggedInUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: <Widget>[
          CupertinoButton(
            child: Icon(
              Icons.add_circle_outline,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute<void>(
                  builder: (context) {
                    return SearchUsersScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                child: StreamBuilder<List<Chat>>(
                    stream: chatStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.none) {
                        return CupertinoActivityIndicator();
                      }
                      List<Chat> chats = List.from(snapshot.data ??
                          []); // to convert it to editable list
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
    final authService = Provider.of<AuthService>(context, listen: false);
    String otherUserUid = widget.chat.uidsOfMembers
        .where((uid) => uid != authService.loggedInUser.uid)
        .toList()[0];
    otherUserFuture = cloudFirestoreService.getUserWithUid(uid: otherUserUid);
  }

  @override
  Widget build(BuildContext context) {
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
          leading:
              Container(), //ProfilePicture(imageUrl: otherUser.imageUrl, radius: 30),
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
                      widget.chat.lastMessageTimestamp.toString(),
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
          onPress: () {
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute<void>(
                builder: (context) {
                  return ChatScreen(
                    chatId: widget.chat.chatId,
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
