import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/models/user.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<User>(context);
    return Container(
        color: Colors.yellow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(loggedInUser.username),
            CupertinoButton(
                child: Text("Sign Out"),
                onPressed: () async {
                  final authService =
                      Provider.of<AuthService>(context, listen: false);
                  await authService.signOut();
                }),
          ],
        ));
  }
}
