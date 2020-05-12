import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/registration/create_profile_screen.dart';
import 'package:voices/screens/tabs_screen.dart';
import 'package:voices/services/permission_service.dart';
import 'package:voices/shared_widgets/next_button.dart';
import 'package:voices/shared_widgets/info_dialog.dart';

class PermissionsScreen extends StatelessWidget {
  final bool moveOnToNextRegistrationScreenAfter;

  PermissionsScreen({this.moveOnToNextRegistrationScreenAfter = false});

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
                  "Please allow Voices to access your microphone, recognize your voice, access your contacts and your camera/photos",
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
                await permissionService.askForAllPermissions();

                //check if the user denied some permissions and if so tell him to press access again
                if (permissionService.getDeniedPermissions().isNotEmpty) {
                  showInfoDialog(
                    context: context,
                    dialog: InfoDialog(
                      title: "You need to click ok on all popups",
                      text: "Please click Allow again",
                    ),
                  );
                  return;
                }

                List<OurPermission> permanentlyDeniedPermissions =
                    permissionService.getPermanentlyDeniedPermissions();
                if (permanentlyDeniedPermissions.isNotEmpty) {
                  String text = "Please allow ";
                  if (permanentlyDeniedPermissions.length == 1) {
                    text += permanentlyDeniedPermissions[0].toString();
                    text += " in your settings";
                  } else if (permanentlyDeniedPermissions.length == 2) {
                    text += permanentlyDeniedPermissions[0].toString();
                    text += " and ";
                    text += permanentlyDeniedPermissions[1].toString();
                    text += " in your settings";
                  } else {
                    for (int i = 0;
                        i < permanentlyDeniedPermissions.length;
                        i++) {
                      if (i == 0) {
                        //first element
                        text += permanentlyDeniedPermissions[i].toString();
                      } else if (i != permanentlyDeniedPermissions.length - 1) {
                        //not last element
                        text +=
                            ", " + permanentlyDeniedPermissions[i].toString();
                      } else {
                        //last element
                        text += " and " +
                            permanentlyDeniedPermissions[i].toString();
                        text += " in your settings";
                      }
                    }
                  }

                  showInfoDialog(
                    context: context,
                    dialog: InfoDialog(
                      title: "Please enable in settings",
                      text: text,
                    ),
                  );
                  return;
                }

                //the user can only use the app if he has granted all permissions
                if (permissionService.areAllPermissionsGranted()) {
                  //user can move on
                  if (moveOnToNextRegistrationScreenAfter) {
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) => CreateProfileScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) => TabsScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                }
              },
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
