import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/screens/navigation_screen.dart';
import 'create_profile_screen.dart';
import 'package:voices/shared widgets/animated_voices_text.dart';

///commented out for development purposes
//import 'package:voices/screens/enter_code_screen.dart';
//import 'package:voices/services/auth_service.dart';
//import 'package:voices/shared%20widgets/info_dialog.dart';

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
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              VoicesAnimated(),
              SizedBox(height: 20.0,),
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

    ///commented out for development purposes
//      Navigator.of(context).pushAndRemoveUntil(
//        CupertinoPageRoute(
//            builder: (context) => CreateProfileScreen(user: newUser)),
//        (Route<dynamic> route) => false,
//      );
//    };
//    final Function whatTodoWhenExistingUserVerified =
//        (User existingUser) async {
//      Navigator.of(context).pushAndRemoveUntil(
//        CupertinoPageRoute(builder: (context) => NavigationScreen()),
//        (Route<dynamic> route) => false,
//      );
//    };
//
//    final Function whatTodoWhenVerificationFailed = (String errorMessage) {
//      setState(() {
//        _showSpinner = false;
//      });
//      showInfoDialog(
//          context: context,
//          dialog: InfoDialog(title: "Verification failed", text: errorMessage));
//    };
//
//    final Function whatTodoWhenSmsSent = () {
//      setState(() {
//        _showSpinner = false;
//      });
//      Navigator.of(context)
//          .push(CupertinoPageRoute(builder: (context) => EnterCodeScreen()));
//    };
//    final authService = Provider.of<AuthService>(context, listen: false);
//    await authService.verifyPhoneNumberAutomaticallyOrSendCode(
//        phoneNumber: _phoneNumber,
//        whatTodoWhenNewUserVerified: whatTodoWhenNewUserVerified,
//        whatTodoWhenExistingUserVerified: whatTodoWhenExistingUserVerified,
//        whatTodoWhenVerificationFailed: whatTodoWhenVerificationFailed,
//        whatTodoWhenSmsSent: whatTodoWhenSmsSent);

    ///start code for development purposes
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    User user = await cloudFirestoreService.getUserWithPhoneNumber(
        phoneNumber: _phoneNumber);
    if (user == null) {
      //create new user
      User newUser = User(uid: _phoneNumber, phoneNumber: _phoneNumber);
      await cloudFirestoreService.uploadUser(user: newUser);
      setState(() {
        _showSpinner = false;
      });
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
            builder: (context) => CreateProfileScreen(user: newUser)),
        (Route<dynamic> route) => false,
      );
    } else {
      //go to navigation screen and pass the user instead of signing in
      setState(() {
        _showSpinner = false;
      });
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
            builder: (context) => NavigationScreen(
                  loggedInUser: user,
                )),
        (Route<dynamic> route) => false,
      );
    }

    ///end code for development purposes
  }
}
