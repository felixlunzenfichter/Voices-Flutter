import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  String verificationId;

  Stream<FirebaseUser> onAuthStateChanged() {
    return _auth.onAuthStateChanged;
  }

  Future<FirebaseUser> getCurrentUser() async {
    final user = await _auth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }

  verifyPhoneNumberAutomaticallyOrSendCode(
      {@required String phoneNumber,
      @required Function whatTodoWhenVerified,
      @required Function whatTodoWhenVerificationFailed,
      @required Function whatTodoWhenSmsSent}) async {
    try {
      final PhoneVerificationCompleted onVerified =
          (AuthCredential credential) async {
        AuthResult result = await _signInWithCredential(credential);
        whatTodoWhenVerified(result.user);
      };
      final PhoneVerificationFailed onFailed = (AuthException authException) {
        whatTodoWhenVerificationFailed(authException.message);
      };
      final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
        verificationId = verId;
      };
      final PhoneCodeSent onSmsSent = (String verId, [int forceResend]) {
        verificationId = verId;
        whatTodoWhenSmsSent();
      };
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: Duration(seconds: 5),
          verificationCompleted: onVerified,
          verificationFailed: onFailed,
          codeSent: onSmsSent,
          codeAutoRetrievalTimeout: autoTimeout);
    } catch (e) {
      print("Could not verify phone number because of error: $e");
    }
  }

  checkEnteredCode(
      {@required String code,
      @required Function onSuccess,
      @required Function onFail}) async {
    AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: code);

    AuthResult result = await _signInWithCredential(credential);
    FirebaseUser user = result.user;
    if (user == null) {
      onFail();
    } else {
      onSuccess(user);
    }
  }

  Future<AuthResult> _signInWithCredential(AuthCredential credential) async {
    AuthResult result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return result;
  }
}
