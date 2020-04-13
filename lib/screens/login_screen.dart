import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/navigation_screen.dart';
import 'package:voices/services/auth_service.dart';
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
              Row(
                children: <Widget>[
                  Text('+41'),
                  Expanded(
                    child: CupertinoTextField(
                      placeholder: 'Enter your phone number',
                      keyboardType: TextInputType.number,
                      onChanged: (newNumber) {
                        _phoneNumber = newNumber;
                      },
                    ),
                  ),
                ],
              ),
              CupertinoButton(
                child: Text('Verify'),
                onPressed: () async {
                  setState(() {
                    _showSpinner = true;
                  });
                  final authService =
                      Provider.of<AuthService>(context, listen: false);
                  _phoneNumber = '+41' + _phoneNumber;
                  print('before starting verification');
                  await authService.verifyPhoneNumberAutomaticallyOrSendCode(
                      phoneNumber: _phoneNumber,
                      onVerificationCompleted:
                          _onAutomaticVerificationCompleted,
                      onVerificationFailed: _onAutomaticVerificationFailed,
                      onCodeSent: _onCodeSent,
                      onCodeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout);
                  setState(() {
                    _showSpinner = false;
                  });
                },
              ),
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
                      child: Text('Click after code entered'),
                      onPressed: () async {
                        final authService =
                            Provider.of<AuthService>(context, listen: false);
                        AuthResult authResult =
                            await authService.signInWithSmsCode(
                                verificationID: _verificationID,
                                smsCode: _smsCode);
                        if (authResult.user != null) {
                          print('Sms code verification successful');
                          _onAuthenticationSuccessful(
                              firebaseUser: authResult.user);
                        } else {
                          print('Sms code entered was wrong');
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  _onAutomaticVerificationCompleted(authCredential) async {
    print('_onAutomaticVerificationCompleted called');
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _showSpinner = true;
    });
    AuthResult authResult =
        await authService.signInWithCredential(credential: authCredential);
    setState(() {
      _showSpinner = false;
    });
    if (authResult.user != null) {
      print('authentication successful');
      _onAuthenticationSuccessful(firebaseUser: authResult.user);
    } else {
      print('authentication failed');
      setState(() {
        _hasToTypeCode = true;
      });
    }
  }

  _onAutomaticVerificationFailed(authException) {
    print('_onAutomaticVerificationFailed called');
    print('verification failed with message = ${authException.message}');
    if (authException.message.contains('Network')) {
      print('please check your internet connection');
    }
  }

  _onCodeSent(verificationId, [forceResendingToken]) {
    print('_onCodeSent called');
    _verificationID = verificationId;
    print('code sent to $_phoneNumber');
  }

  _onCodeAutoRetrievalTimeout(verificationId) {
    print('_onCodeAutoRetrievalTimeout called');
    _verificationID = verificationId;
    print('auto retrieval timed out');
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
