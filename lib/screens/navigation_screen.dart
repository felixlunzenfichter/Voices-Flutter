import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'profile_tab.dart';
import 'chats_tab.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:voices/models/user.dart';
import 'package:voices/services/cloud_firestore_service.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  FirebaseUser loggedInUser;

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
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    return StreamProvider<User>.value(
      value: cloudFirestoreService.getUserStream(uid: loggedInUser?.uid),
      catchError: (context, object) {
        return null;
      },
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
                Icons.account_circle,
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
                  child: ProfileTab(),
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
    setState(() {
      loggedInUser = firebaseUser;
    });
  }
}
