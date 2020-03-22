import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

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
      @required Function onVerificationCompleted,
      @required Function onVerificationFailed,
      @required Function onCodeSent,
      @required Function onCodeAutoRetrievalTimeout}) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 5),
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout);
  }

  Future<AuthResult> signInWithCredential(
      {@required AuthCredential credential}) async {
    AuthResult authResult = await _auth.signInWithCredential(credential);
    return authResult;
  }

  Future<AuthResult> signInWithSmsCode(
      {@required String verificationID, @required String smsCode}) async {
    AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationID, smsCode: smsCode);
    AuthResult authResult = await _auth.signInWithCredential(credential);
    return authResult;
  }
}
