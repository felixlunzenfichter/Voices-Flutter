import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/navigation_screen.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/models/user.dart';
import 'create_profile_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:voices/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showSpinner = false;
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      progressIndicator: CupertinoActivityIndicator(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login with phone number'),
        ),
        backgroundColor: Colors.purple,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              CupertinoTextField(
                placeholder: 'Enter your phone number',
                keyboardType: TextInputType.number,
                onChanged: (newNumber) {
                  _phoneNumber = newNumber;
                },
              ),
              CupertinoButton(
                  child: Text('Verify'), onPressed: _verifyPhoneNumber),
            ],
          ),
        ),
      ),
    );
  }

  _verifyPhoneNumber() async {
    setState(() {
      _showSpinner = true;
    });
    print('before starting verification');

    final Function whatTodoWhenVerificationSuccessful =
        (FirebaseUser firebaseUser) async {
      print("Verified caaaaaaaaaaaaaaallleeeeed");
      _checkIfUserAlreadyExistsAndNavigate(firebaseUser: firebaseUser);
    };

    final Function whatTodoWhenVerificationFailed = (String errorMessage) {
      print("Failed caaaaaaaaaaaaaaallleeeeed");
      //todo show the user that it failed
      print(errorMessage);
    };

    final Function whatTodoWhenSmsSent = () {
      print("whatTodoWhenSmsSent caaaaaaaaaaaaaaallleeeeed");
      //todo add verification id and navigate to codescreen
    };
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.verifyPhoneNumberAutomaticallyOrSendCode(
        phoneNumber: _phoneNumber,
        whatTodoWhenVerified: whatTodoWhenVerificationSuccessful,
        whatTodoWhenVerificationFailed: whatTodoWhenVerificationFailed,
        whatTodoWhenSmsSent: whatTodoWhenSmsSent);
    setState(() {
      _showSpinner = false;
    });
  }

  _checkIfUserAlreadyExistsAndNavigate(
      {@required FirebaseUser firebaseUser}) async {
    print('_onAuthenticationSuccessful called');
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    setState(() {
      _showSpinner = true;
    });
    User user = await cloudFirestoreService.getUserWithPhoneNumber(
        phoneNumber: _phoneNumber);
    setState(() {
      _showSpinner = false;
    });
    if (user == null) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
            builder: (context) =>
                CreateProfileScreen(firebaseUser: firebaseUser)),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => NavigationScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
