import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'settings_tab.dart';
import 'chats_tab.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';

///commented out for development purposes
//import 'package:voices/services/auth_service.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'login_screen.dart';
//import 'package:voices/services/cloud_firestore_service.dart';

class NavigationScreen extends StatefulWidget {
  ///start of code for development purposes
  final User loggedInUser;
  NavigationScreen({@required this.loggedInUser});

  ///end of code for development purposes

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  ///commented out for development purposes
//  User loggedInUser;
//
//  @override
//  void initState() {
//    super.initState();
//    _getLoggedInUser();
//  }

  @override
  Widget build(BuildContext context) {
    ///commented out for development purposes
//    if (loggedInUser == null) {
//      return LoginScreen();
//    }
    return Provider<User>.value(
      value: widget.loggedInUser,

      /// widget.loggedInUser instead of loggedInUser for development purposes
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Colors.white,
          activeColor: Colors.black,
          inactiveColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
              ),
            ),
          ],
        ),
        tabBuilder: (context, index) {
          CupertinoTabView returnValue;
          switch (index) {
            case 0:
              returnValue = CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                  child: ChatsTab(),
                );
              });
              break;
            case 1:
              returnValue = CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                  child: SettingsTab(),
                );
              });
              break;
          }
          return returnValue;
        },
      ),
    );
  }

  ///commented out for development purposes
//  _getLoggedInUser() async {
//    final authService = Provider.of<AuthService>(context, listen: false);
//    FirebaseUser firebaseUser = await authService.getCurrentUser();
//    final cloudFirestoreService =
//        Provider.of<CloudFirestoreService>(context, listen: false);
//    User user =
//        await cloudFirestoreService.getUserWithUid(uid: firebaseUser.uid);
//    setState(() {
//      loggedInUser = user;
//    });
//  }
}
