import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voices/screens/registration/permissions_screen.dart';
import 'settings_tab.dart';
import 'chats_tab.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

class TabsOrPermissionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final permissionService = Provider.of<PermissionService>(context);
    if (permissionService.microphonePermissionStatus !=
            PermissionStatus.granted ||
        permissionService.speechRecognitionPermissionStatus !=
            PermissionStatus.granted) {
      return PermissionsScreen();
    } else {
      return TabsScreen();
    }
  }
}

class TabsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
