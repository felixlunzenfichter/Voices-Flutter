import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/permission_service.dart';
import 'package:voices/screens/navigation_screen.dart';

class AskForPermissionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Permissions"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
              "Please allow Voices to access your microphone and recognize you voice"),
          CupertinoButton(
            child: Text("Allow"),
            onPressed: () async {
              final permissionService =
                  Provider.of<PermissionService>(context, listen: false);
              await permissionService.askForMicrophonePermission();
              await permissionService.askForSpeechRecognitionPermission();

              switch (permissionService.microphonePermissionStatus) {
                case PermissionStatus.denied:
                  //todo tell the user he can't use the app like this and that he has to allow it
                  break;
                case PermissionStatus.permanentlyDenied:
                  //todo tell the user he can't use the app like this and he has to go to settings (iOS) to enable it
                  break;
                case PermissionStatus.restricted:
                  //todo tell the user he can't use the app like this because he doesn't have the rights to do so
                  break;
                default:
                  break;
              }
              switch (permissionService.speechRecognitionPermissionStatus) {
                case PermissionStatus.denied:
                  //todo tell the user he can't use the app like this and that he has to allow it
                  break;
                case PermissionStatus.permanentlyDenied:
                  //todo tell the user he can't use the app like this and he has to go to settings (iOS) to enable it
                  break;
                case PermissionStatus.restricted:
                  //todo tell the user he can't use the app like this because he doesn't have the rights to do so
                  break;
                default:
                  break;
              }

              //the user can only use the app if he has granted all permissions
              if (permissionService.microphonePermissionStatus ==
                      PermissionStatus.granted &&
                  permissionService.speechRecognitionPermissionStatus ==
                      PermissionStatus.granted) {
                Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(
                    builder: (context) => NavigationScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            },
          )
        ],
      ),
    );
  }
}
