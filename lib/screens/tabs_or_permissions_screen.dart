import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voices/screens/registration/permissions_screen.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'tabs_screen.dart';

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
