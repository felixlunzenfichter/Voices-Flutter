import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voices/models/user.dart';
import 'package:voices/models/message.dart';

class CloudFirestoreService {
  final _fireStore = Firestore.instance;

  Future<void> uploadUser({@required User user}) async {
    try {
      _fireStore
          .collection('users')
          .document(user.uid)
          .setData(user.toMap(), merge: true);
    } catch (e) {
      print('Could not upload user info');
      debugPrint('error: $e');
    }
  }

  Future<User> getUser({@required String uid}) async {
    try {
      var userDocument =
          await _fireStore.collection('users').document(uid).get();
      if (userDocument.data == null) {
        print('Could not get user info1');
        return null;
      }

      return User.fromMap(map: userDocument.data);
    } catch (e) {
      print('Could not get user with uid = $uid');
      print(e);
      return null;
    }
  }

  Future<User> getUserWithPhoneNumber({@required String phoneNumber}) async {
    try {
      QuerySnapshot snap = await _fireStore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .getDocuments();

      var userDocuments = snap.documents;
      if (userDocuments.isEmpty) {
        return null;
      } else {
        User user = User.fromMap(map: userDocuments[0].data);
        return user;
      }
    } catch (e) {
      print('Could not get user with phone number = $phoneNumber');
      print(e);
      return null;
    }
  }

  Future<User> getUserWithUsername({@required String username}) async {
    try {
      QuerySnapshot snap = await _fireStore
          .collection('users')
          .where('username', isEqualTo: username)
          .getDocuments();

      var userDocuments = snap.documents;
      if (userDocuments.isEmpty) {
        return null;
      } else {
        User user = User.fromMap(map: userDocuments[0].data);
        return user;
      }
    } catch (e) {
      print('Could not get user with username = $username');
      print(e);
      return null;
    }
  }

  Stream<User> getUserStream({@required String uid}) {
    try {
      return _fireStore
          .collection('users')
          .document(uid)
          .snapshots()
          .map((doc) => User.fromMap(map: doc.data));
    } catch (e) {
      print('Could not get the user stream');
    }
    return Stream.empty();
  }

  Future<void> uploadChatBlocked(
      {@required String chatpath,
      bool hasUser1Blocked,
      bool hasUser2Blocked}) async {
    if (hasUser1Blocked != null) {
      await _fireStore
          .document(chatpath)
          .updateData({'hasUser1Blocked': hasUser1Blocked});
    } else if (hasUser2Blocked != null) {
      await _fireStore
          .document(chatpath)
          .updateData({'hasUser2Blocked': hasUser2Blocked});
    }
    return null;
  }

  Stream<List<Message>> getMessageStream({@required String chatPath}) {
    try {
      var messageStream = _fireStore
          .document(chatPath)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots()
          .map((snap) => snap.documents.reversed
              .map((doc) => Message.fromMap(map: doc.data))
              .toList());
      return messageStream;
    } catch (e) {
      print('Could not get the message stream');
    }
    return Stream.empty();
  }

  Future<void> uploadMessage(
      {@required String chatPath, @required Message message}) async {
    try {
      await _fireStore
          .document(chatPath)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      print('Could not upload message');
    }
  }

  Future<void> uploadUsersPushToken(
      {@required String uid, @required String pushToken}) async {
    try {
      _fireStore
          .collection('users')
          .document(uid)
          .updateData({'pushToken': pushToken});
    } catch (e) {
      print('Could not upload push token');
    }
  }
}
