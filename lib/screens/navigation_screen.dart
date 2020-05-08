import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'settings_tab.dart';
import 'chats_tab.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/screens/registration/login_screen.dart';

import 'package:voices/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voices/services/cloud_firestore_service.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  User loggedInUser;

  @override
  void initState() {
    super.initState();
    _getLoggedInUser();
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUser == null) {
      return LoginScreen();
    }
    return Provider<User>.value(
      value: loggedInUser,
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

  _getLoggedInUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    FirebaseUser firebaseUser = await authService.getCurrentUser();
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    User user =
        await cloudFirestoreService.getUserWithUid(uid: firebaseUser.uid);
    setState(() {
      loggedInUser = user;
    });
  }
}
