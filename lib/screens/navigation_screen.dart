import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'settings_tab.dart';
import 'chats_tab.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/screens/registration/login_screen.dart';

class NavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<User>(context);
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
    );
  }
}
