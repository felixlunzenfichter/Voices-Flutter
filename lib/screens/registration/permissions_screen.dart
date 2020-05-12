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
    final permissionService =
        Provider.of<PermissionService>(context, listen: false);
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
                await permissionService.askForAllPermissions();

                List<OurPermission> notGrantedPermissions =
                    permissionService.getNotGrantedPermissions();
                if (notGrantedPermissions.isNotEmpty) {
                  String text = "Please allow ";
                  if (notGrantedPermissions.length == 1) {
                    text += notGrantedPermissions[0].toString();
                    text += " in your settings";
                  } else if (notGrantedPermissions.length == 2) {
                    text += notGrantedPermissions[0].toString();
                    text += " and ";
                    text += notGrantedPermissions[1].toString();
                    text += " in your settings";
                  } else {
                    for (int i = 0; i < notGrantedPermissions.length; i++) {
                      if (i == 0) {
                        //first element
                        text += notGrantedPermissions[i].toString();
                      } else if (i != notGrantedPermissions.length - 1) {
                        //not last element
                        text += ", " + notGrantedPermissions[i].toString();
                      } else {
                        //last element
                        text += " and " + notGrantedPermissions[i].toString();
                        text += " in your settings";
                      }
                    }
                  }

                  showInfoDialog(
                    context: context,
                    dialog: InfoDialog(
                      title: "Ungranted permission",
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
