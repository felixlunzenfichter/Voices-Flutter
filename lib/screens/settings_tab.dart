import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/registration/login_screen.dart';
import 'package:voices/shared_widgets/profile_picture.dart';

import 'package:voices/services/logged_in_user_service.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<LoggedInUserService>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ProfilePicture(
          imageUrl: authService.loggedInUser.imageUrl,
          radius: 60,
        ),
        Material(
          //material is needed to remove the underline under the text
          child: Text(
            authService.loggedInUser.username,
            textAlign: TextAlign.center,
          ),
        ),
        CupertinoButton(
            child: Text("Sign Out"),
            onPressed: () async {
              await Navigator.of(context, rootNavigator: true)
                  .pushAndRemoveUntil(
                CupertinoPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
              authService.signOut();
            }),
      ],
    );
  }
}
