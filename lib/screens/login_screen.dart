import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/enter_code_screen.dart';
import 'package:voices/screens/navigation_screen.dart';
import 'package:voices/models/user.dart';
import 'package:voices/shared%20widgets/info_dialog.dart';
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

    final Function whatTodoWhenNewUserVerified = (User newUser) async {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
            builder: (context) => CreateProfileScreen(user: newUser)),
        (Route<dynamic> route) => false,
      );
    };
    final Function whatTodoWhenExistingUserVerified =
        (User existingUser) async {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => NavigationScreen()),
        (Route<dynamic> route) => false,
      );
    };

    final Function whatTodoWhenVerificationFailed = (String errorMessage) {
      setState(() {
        _showSpinner = false;
      });
      showInfoDialog(
          context: context,
          dialog: InfoDialog(title: "Verification failed", text: errorMessage));
    };

    final Function whatTodoWhenSmsSent = () {
      setState(() {
        _showSpinner = false;
      });
      Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) => EnterCodeScreen()));
    };
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.verifyPhoneNumberAutomaticallyOrSendCode(
        phoneNumber: _phoneNumber,
        whatTodoWhenNewUserVerified: whatTodoWhenNewUserVerified,
        whatTodoWhenExistingUserVerified: whatTodoWhenExistingUserVerified,
        whatTodoWhenVerificationFailed: whatTodoWhenVerificationFailed,
        whatTodoWhenSmsSent: whatTodoWhenSmsSent);
  }
}
