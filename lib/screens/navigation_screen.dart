import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voices/screens/registration/ask_for_permissions_screen.dart';
import 'settings_tab.dart';
import 'chats_tab.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/screens/registration/login_screen.dart';
import 'package:voices/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<User>(context);
    final permissionService = Provider.of<PermissionService>(context);
    if (loggedInUser == null) {
      return LoginScreen();
    } else if (permissionService.microphonePermissionStatus !=
            PermissionStatus.granted ||
        permissionService.speechRecognitionPermissionStatus !=
            PermissionStatus.granted) {
      return AskForPermissionsScreen();
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
