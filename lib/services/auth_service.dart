import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:voices/services/cloud_firestore_service.dart';

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

  ///whatTodoWhenNewUserVerified is the function to be called with the newly created user as an argument if the phone number got verified
  ///whatTodoWhenExistingUserVerified is the function to be called with the existing user in the users collection as an argument if the phone number got verified
  ///whatTodoWhenVerificationFailed is the function to be called without arguments if the verification failed
  ///whatTodoWhenSmsSent is the function to be called without arguments if the code was sent
  Future<void> verifyPhoneNumberAutomaticallyOrSendCode(
      {@required String phoneNumber,
      @required Function whatTodoWhenNewUserVerified,
      @required Function whatTodoWhenExistingUserVerified,
      @required Function whatTodoWhenVerificationFailed,
      @required Function whatTodoWhenSmsSent}) async {
    try {
      final PhoneVerificationCompleted onVerified =
          (AuthCredential credential) async {
        AuthResult result = await _signInWithCredential(credential);
        CloudFirestoreService firestoreService = CloudFirestoreService();
        await firestoreService.checkIfUserExists(
            phoneNumber: phoneNumber,
            uid: result.user.uid,
            whatToDoWhenUserNew: whatTodoWhenNewUserVerified,
            whatToDoWhenUserAlreadyExists: whatTodoWhenVerificationFailed);
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

  ///whatTodoWhenCodeCorrectForNewUser is the function to be called with the newly created user as an argument if the code is correct
  ///whatTodoWhenCodeCorrectForExistingUser is the function to be called with the existing user in the users collection as an argument if the code is correct
  ///whatTodoWhenCodeFalse is the function to be called without arguments if the code was wrong
  checkEnteredCode(
      {@required String code,
      @required Function whatTodoWhenCodeCorrectForNewUser,
      @required Function whatTodoWhenCodeCorrectForExistingUser,
      @required Function whatTodoWhenCodeFalse}) async {
    AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: code);

    AuthResult result = await _signInWithCredential(credential);
    FirebaseUser user = result.user;
    if (user == null) {
      whatTodoWhenCodeFalse();
    } else {
      CloudFirestoreService firestoreService = CloudFirestoreService();
      await firestoreService.checkIfUserExists(
          phoneNumber: user.phoneNumber,
          uid: user.uid,
          whatToDoWhenUserNew: whatTodoWhenCodeCorrectForNewUser,
          whatToDoWhenUserAlreadyExists:
              whatTodoWhenCodeCorrectForExistingUser);
    }
  }

  Future<AuthResult> _signInWithCredential(AuthCredential credential) async {
    AuthResult result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return result;
  }
}
