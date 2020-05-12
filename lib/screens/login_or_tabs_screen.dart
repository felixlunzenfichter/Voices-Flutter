import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voices/screens/tabs_or_permissions_screen.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/registration/login_screen.dart';
import 'package:voices/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginOrTabsScreen extends StatefulWidget {
  @override
  _LoginOrTabsScreenState createState() => _LoginOrTabsScreenState();
}

class _LoginOrTabsScreenState extends State<LoginOrTabsScreen> {
  FirebaseUser loggedInUser;

  @override
  void initState() {
    super.initState();
    _setLoggedInUser();
  }

  @override
  Widget build(BuildContext context) {
    print("loggedInUser = $loggedInUser");
    if (loggedInUser == null) {
      return LoginScreen();
    } else {
      return TabsOrPermissionsScreen();
    }
  }

  _setLoggedInUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    var firebaseUser = await authService.getCurrentUser();
    print(
        "the loggedInUser = $firebaseUser has phone number = ${firebaseUser?.phoneNumber}");
    if (firebaseUser != null) {
      setState(() {
        loggedInUser = firebaseUser;
      });
    }
  }
}
