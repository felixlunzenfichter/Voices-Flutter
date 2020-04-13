import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/navigation_screen.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/models/user.dart';
import 'create_profile_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showSpinner = false;
  String _phoneNumber = '';
  String _verificationID;
  String _smsCode;
  bool _hasToTypeCode = false;

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
              if (_hasToTypeCode)
                Column(
                  children: <Widget>[
                    CupertinoTextField(
                      placeholder: 'Enter the code here',
                      keyboardType: TextInputType.number,
                      onChanged: (newCode) {
                        _smsCode = newCode;
                      },
                    ),
                    CupertinoButton(
                        child: Text('Check Code'),
                        onPressed: _checkEnteredCode),
                  ],
                ),
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

    final PhoneVerificationCompleted verified =
        (AuthCredential credential) async {
      print("Verified caaaaaaaaaaaaaaallleeeeed");
      AuthResult result = await _signInWithCredential(credential);
      _onAuthenticationSuccessful(firebaseUser: result.user);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      print("Failed caaaaaaaaaaaaaaallleeeeed");
      print(authException.message);
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      print("smsSent caaaaaaaaaaaaaaallleeeeed");
      this._verificationID = verId;
      setState(() {
        _hasToTypeCode = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      print("autoTimeout caaaaaaaaaaaaaaallleeeeed");
      this._verificationID = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
    setState(() {
      _showSpinner = false;
    });
  }

  _checkEnteredCode() async {
    AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: _verificationID, smsCode: _smsCode);

    AuthResult result = await _signInWithCredential(credential);

    if (result.user != null) {
      print('Sms code verification successful');
      _onAuthenticationSuccessful(firebaseUser: result.user);
    } else {
      print('Sms code entered was wrong');
    }
  }

  Future<AuthResult> _signInWithCredential(AuthCredential credential) async {
    AuthResult result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return result;
  }

  _onAuthenticationSuccessful({@required FirebaseUser firebaseUser}) async {
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
