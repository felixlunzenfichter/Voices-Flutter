import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'search_tab.dart';
import 'chats_tab.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

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
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
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
                child: SearchTab(),
              );
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: ChatsTab(),
              );
            });
            break;
        }
        return returnValue;
      },
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
