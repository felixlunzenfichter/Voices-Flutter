import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/login_screen.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        child: loggedInUser == null
            ? Container()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: loggedInUser.imageUrl,
                    imageBuilder: (context, imageProvider) {
                      return CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey,
                          backgroundImage: imageProvider);
                    },
                    placeholder: (context, url) => SizedBox(
                      height: 120,
                      child: CupertinoActivityIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  Text(loggedInUser.username),
                  CupertinoButton(
                      child: Text("Sign Out"),
                      onPressed: () async {
                        final authService =
                            Provider.of<AuthService>(context, listen: false);
                        await authService.signOut();
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                          CupertinoPageRoute(
                              builder: (context) => LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                      }),
                ],
              ));
  }
}
