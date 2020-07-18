import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:voices/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/shared_widgets/custom_card.dart';
import 'package:voices/shared_widgets/profile_picture.dart';
import 'chat_screen/chat_screen.dart';

class SearchUsersScreen extends StatefulWidget {
  @override
  _SearchUsersScreenState createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  Future<List<User>> allUsersFuture;
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    allUsersFuture = cloudFirestoreService.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<LoggedInUserService>(context, listen: false);
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      progressIndicator: CupertinoActivityIndicator(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search Users'),
        ),
        body: FutureBuilder(
          future: allUsersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return CupertinoActivityIndicator();
            }
            if (snapshot.hasError) {
              return Container(
                color: Colors.red,
                child: Text("An error occured: ${snapshot.error.toString()}"),
              );
            }

            List<User> allUsers = List.from(snapshot.data);
            allUsers.removeWhere(
                (user) => user.uid == authService.loggedInUser.uid);

            if (allUsers.isEmpty) {
              return Center(
                child: Text("There are no users"),
              );
            }

            return ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                User user = allUsers[index];
                return UserItem(
                    user: user,
                    onPress: () {
                      _whatTodoWhenUserItemIsPressed(user: user);
                    });
              },
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
            );
          },
        ),
      ),
    );
  }

  _whatTodoWhenUserItemIsPressed({@required User user}) async {
    setState(() {
      _showSpinner = true;
    });
    final authService =
        Provider.of<LoggedInUserService>(context, listen: false);
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    String chatId = await cloudFirestoreService.getChatWithUsers(
        uid1: authService.loggedInUser.uid, uid2: user.uid);
    setState(() {
      _showSpinner = false;
    });
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute<void>(
        builder: (context) {
          return ChatScreen(
            chatId: chatId,
            otherUser: user,
          );
        },
      ),
    );
  }
}

class UserItem extends StatelessWidget {
  final User user;
  final Function onPress;

  UserItem({@required this.user, @required this.onPress});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      leading: ProfilePicture(imageUrl: user.imageUrl, radius: 30),
      middle: Text(
        user.username,
        overflow: TextOverflow.ellipsis,
      ),
      onPress: onPress,
    );
  }
}
