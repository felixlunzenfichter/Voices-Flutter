import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/tabs_or_permissions_screen.dart';
import 'package:voices/services/permission_service.dart';
import 'package:voices/shared_widgets/next_button.dart';
import 'package:voices/shared_widgets/info_dialog.dart';

class PermissionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Text(
                  "Please allow Voices to access your microphone and recognize your voice",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            NextButton(
              text: "Allow",
              onPressed: () async {
                final permissionService =
                    Provider.of<PermissionService>(context, listen: false);
                await permissionService.askForMicrophonePermission();
                await permissionService.askForSpeechRecognitionPermission();

                switch (permissionService.microphonePermissionStatus) {
                  case PermissionStatus.denied:
                    showInfoDialog(
                      context: context,
                      dialog: InfoDialog(
                        title: "You denied Voices the permissions it needs",
                        text:
                            "Please press allow again and give voices the necessary permissions",
                      ),
                    );
                    break;
                  case PermissionStatus.permanentlyDenied:
                    showInfoDialog(
                      context: context,
                      dialog: InfoDialog(
                        title: "Enable microphone usage in settings",
                        text:
                            "Please go to your settings and give Voices permission to use your microphone",
                      ),
                    );
                    break;
                  case PermissionStatus.restricted:
                    showInfoDialog(
                      context: context,
                      dialog: InfoDialog(
                        title: "Your access is restricted",
                        text:
                            "It seems like you are not allowed to use this app",
                      ),
                    );
                    break;
                  default:
                    break;
                }
                switch (permissionService.speechRecognitionPermissionStatus) {
                  case PermissionStatus.denied:
                    showInfoDialog(
                      context: context,
                      dialog: InfoDialog(
                        title: "You denied Voices the permissions it needs",
                        text:
                            "Please press allow again and give voices the necessary permissions",
                      ),
                    );
                    break;
                  case PermissionStatus.permanentlyDenied:
                    showInfoDialog(
                      context: context,
                      dialog: InfoDialog(
                        title: "Enable speech recogition in settings",
                        text:
                            "Please go to your settings and give Voices permission to use speech to text",
                      ),
                    );
                    break;
                  case PermissionStatus.restricted:
                    showInfoDialog(
                      context: context,
                      dialog: InfoDialog(
                        title: "Your access is restricted",
                        text:
                            "It seems like you are not allowed to use this app",
                      ),
                    );
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
                      builder: (context) => TabsOrPermissionsScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
