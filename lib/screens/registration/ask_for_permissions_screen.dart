import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/services/permission_service.dart';
import 'package:voices/screens/navigation_screen.dart';

class AskForPermissionsScreen extends StatelessWidget {
  final User user;

  AskForPermissionsScreen({@required this.user});

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

              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                  builder: (context) => NavigationScreen(
                    loggedInUser: user,
                  ),
                ),

                ///NavigationScreen takes argument for development purposes
                (Route<dynamic> route) => false,
              );
            },
          )
        ],
      ),
    );
  }
}
