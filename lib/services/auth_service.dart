import 'dart:async';
import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:voices/models/user.dart';
import 'package:voices/services/cloud_firestore_service.dart';

/// This [ChangeNotifier] Manages the state of the currently logged in user.
/// 
/// This class handles user authentication.
/// The state of the current user is provided to the
/// rest of the app through the [_loggedInUser] property.
/// Other parts of the app don't alter the state of the user through this
/// service, they update the state in the cloud directly.
/// If state of the currently logged in user changes in the cloud it updates
/// the state of the [_loggedInUser] accordingly and notifies the listeners.
class LoggedInUserService with ChangeNotifier {

  /// Global state variables.

  /// The User object is provided to the rest of this app.
  /// If no user is logged in the value is [null].
  User _loggedInUser;
  User get loggedInUser => _loggedInUser;

  /// This Status informs listeners about whether the service
  /// is currently performing a network request.
  bool isFetching = true;


  /// Private state.

  /// Access to the Firebase Authentication service.
  final _auth = FirebaseAuth.instance;

  /// Access to the real time database.
  final _cloudFirestoreService = CloudFirestoreService();

  /// This stream provides the state of the current user.
  StreamSubscription<User> _fireStoreUserScreamSubscription;

  // Todo: What is this?
  String _verificationId;

  LoggedInUserService() {
    _updateLoggedInUser();
  }

  _updateLoggedInUser() async {
    Stream<FirebaseUser> authenticationStream = _auth.onAuthStateChanged;
    /// Wait for new sign in or sign out.
    await for (var firebaseUser in authenticationStream) {
      /// firebaseUser == null means the user signed out and.
      /// firebaseUser != null means the user signed in.
      if (firebaseUser == null) {
        /// Let the rest of the app know that the user logged out.
        _loggedInUser = null;
        /// Done fetching the user.
        isFetching = false;
        notifyListeners();
      } else {
        /// Get the stream for the state of the logged in user.
        Stream<User> fireStoreStream =
            _cloudFirestoreService.getUserStream(uid: firebaseUser.uid);
        _fireStoreUserScreamSubscription?.cancel();
        /// Listen to updates to the state of the logged in user.
        _fireStoreUserScreamSubscription = fireStoreStream.listen((user) {
          _loggedInUser = user;
          isFetching = false;
          notifyListeners();
        }, onError: (error) {
          print(error);
        }, cancelOnError: false);
      }
    }
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }


  Future<void> verifyPhoneNumberAutomaticallyOrSendCode(
      {@required String phoneNumber,
        @required Function whatTodoWhenNewUserVerified,
        @required Function whatTodoWhenExistingUserVerified,
        @required Function whatTodoWhenVerificationFailed,
        @required Function whatTodoWhenSmsSent}) async {
    try {

      /// Call after the phone number has been verified.
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
        _verificationId = verId;
      };
      final PhoneCodeSent onSmsSent = (String verId, [int forceResend]) {
        _verificationId = verId;
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
        verificationId: _verificationId, smsCode: code);

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
