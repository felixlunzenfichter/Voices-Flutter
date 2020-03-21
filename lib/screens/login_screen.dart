import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String phoneNumber = '';
  String verificationID;
  String smsCode;
  bool hasToTypeCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Text('Login with phone number'),
            Row(
              children: <Widget>[
                Text('+41'),
                Expanded(
                  child: CupertinoTextField(
                    placeholder: 'Enter your phone number',
                    keyboardType: TextInputType.number,
                    onChanged: (newNumber) {
                      phoneNumber = newNumber;
                    },
                  ),
                ),
              ],
            ),
            CupertinoButton(
              child: Text('Log In'),
              onPressed: () async {
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                phoneNumber = '+41' + phoneNumber;
                await authService.sendCodeToPhoneNumber(
                    phoneNumber: phoneNumber,
                    onVerificationCompleted: _onAutomaticVerificationCompleted,
                    onVerificationFailed: _onAutomaticVerificationFailed,
                    onCodeSent: _onCodeSent,
                    onCodeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout);
              },
            ),
            if (hasToTypeCode)
              Column(
                children: <Widget>[
                  CupertinoTextField(
                    placeholder: 'Enter the code here',
                    keyboardType: TextInputType.number,
                    onChanged: (newCode) {
                      smsCode = newCode;
                    },
                  ),
                  CupertinoButton(
                    child: Text('Click after code entered'),
                    onPressed: () async {
                      final authService =
                          Provider.of<AuthService>(context, listen: false);
                      AuthResult authResult =
                          await authService.signInWithSmsCode(
                              verificationID: verificationID, smsCode: smsCode);
                      if (authResult.user != null) {
                        print('Sms code verification successful');
                        _onAuthenticationSuccessful();
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
    );
  }

  _onAutomaticVerificationCompleted(authCredential) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    AuthResult authResult =
        await authService.signInWithCredential(credential: authCredential);
    if (authResult.user != null) {
      print('authentication successful');
      _onAuthenticationSuccessful();
    } else {
      print('authentication failed');
      setState(() {
        hasToTypeCode = true;
      });
    }
  }

  _onAutomaticVerificationFailed(authException) {
    print('verification failed with message = ${authException.message}');
    if (authException.message.contains('Network')) {
      print('please check your internet connection');
    }
  }

  _onCodeSent(verificationId, [forceResendingToken]) {
    verificationID = verificationId;
    print('code sent to $phoneNumber');
  }

  _onCodeAutoRetrievalTimeout(verificationId) {
    verificationID = verificationId;
    print('auto retrieval timed out');
  }

  _onAuthenticationSuccessful() {
    //todo navigate away
  }
}
