import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/models/user.dart';
import 'navigation_screen.dart';
import 'create_profile_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  String _smsCode;
  bool _showSpinner;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      progressIndicator: CupertinoActivityIndicator(),
      child: Column(
        children: <Widget>[
          CupertinoTextField(
            placeholder: 'Enter the code here',
            keyboardType: TextInputType.number,
            onChanged: (newCode) {
              _smsCode = newCode;
            },
          ),
          CupertinoButton(
              child: Text('Check Code'), onPressed: _checkEnteredCode),
        ],
      ),
    );
  }

  _checkEnteredCode() async {
    final Function whatTodoWhenCodeCorrect = (FirebaseUser user) async {
      _checkIfUserAlreadyExistsAndNavigate(firebaseUser: user);
      //todo navigate away
    };

    final Function whatTodoWhenCodeFalse = () {
      print("Wrong code");
      //todo show the user that it failed
    };

    final authService = Provider.of<AuthService>(context, listen: false);
    authService.checkEnteredCode(
        code: _smsCode,
        onSuccess: whatTodoWhenCodeCorrect,
        onFail: whatTodoWhenCodeFalse);
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
        phoneNumber: firebaseUser.phoneNumber);
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
