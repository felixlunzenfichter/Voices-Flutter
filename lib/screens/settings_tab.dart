import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/registration/login_screen.dart';
import 'package:voices/models/user.dart';
import 'package:voices/shared_widgets/profile_picture.dart';

import 'package:voices/services/auth_service.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<User>(context);
    return Container(
        color: Colors.yellow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ProfilePicture(
              imageUrl: loggedInUser.imageUrl,
              radius: 60,
            ),
            Text(loggedInUser.username),
            CupertinoButton(
                child: Text("Sign Out"),
                onPressed: () async {
                  final authService =
                      Provider.of<AuthService>(context, listen: false);
                  authService.signOut();

                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    CupertinoPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }),
          ],
        ));
  }
}
