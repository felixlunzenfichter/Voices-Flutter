import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/models/chat.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/shared_widgets/profile_picture.dart';
import 'conversation_screen/conversation_screen.dart';
import 'search_users_screen.dart';
import 'package:voices/shared_widgets/custom_card.dart';

/// See active chats.
class ChatsTab extends StatefulWidget {
  @override
  _ChatsTabState createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  /// This firebase stream provides the active conversations of the current user.
  Stream<List<Chat>> chatStream;

  /// Initialize the [chatStream].
  @override
  void initState() {
    super.initState();

    /// - Services -
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    final authService =
        Provider.of<LoggedInUserService>(context, listen: false);

    /// Get the stream of active conversations for the current user.
    chatStream = cloudFirestoreService.getChatsStream(
        loggedInUid: authService.loggedInUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversations"),
        actions: <Widget>[
          /// Add a new chat to the active ones.
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

                /// List the available chats.
                /// TODO: This is a stateless widget. What if I am on this screen and I receive a message from a user not contained in the chatStream?
                child: StreamBuilder<List<Chat>>(
                    stream: chatStream,
                    builder: (context, snapshot) {
                      /// TODO: If connectionState is none then we should tell the user that he is not connected to the internet.
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.none) {
                        return CupertinoActivityIndicator();
                      }

                      /// Convert this stream to an editable list.
                      List<Chat> chats = List.from(snapshot.data ?? []);

                      /// Sort chats according to time of last message.
                      chats.sort((chat1, chat2) => (chat2.lastMessageTimestamp)
                          .compareTo(chat1.lastMessageTimestamp));

                      /// Inform that no active chats exist.
                      if (chats.isEmpty) {
                        return Center(child: Text("You have no open chats"));
                      }

                      /// Display list of chat tabs.
                      return ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            return ChatItem(chat: chats[index]);
                          });
                    }))
          ],
        ),
      ),
    );
  }
}

/// This widget displays a chat tab.
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

    /// Services
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    final authService =
        Provider.of<LoggedInUserService>(context, listen: false);

    /// Get the uid of the other user. (todo: can this be cleaner?)
    String otherUserUid = widget.chat.uidsOfMembers
        .where((uid) => uid != authService.loggedInUser.uid)
        .toList()[0];

    /// Fetch the other User.
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

        /// Show a chat tab.
        /// TODO: listen to what the other one has to say and automatically enter chat and be ready to respond. Just play last thing that has not been listened to. Quick start of voice communication. Show new messages. Show time of unlistened material.
        return CustomCard(
          /// display profile picture.
          leading: ProfilePicture(imageUrl: otherUser.imageUrl, radius: 30),

          middle: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  /// Show Username
                  Text(
                    otherUser.username,
                    overflow: TextOverflow.ellipsis,
                  ),

                  /// Show time of last message.
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

              /// Display last message.
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

          /// Jump into chat.
          onPress: () {
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute<void>(
                builder: (context) {
                  return ConversationScreen(
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
