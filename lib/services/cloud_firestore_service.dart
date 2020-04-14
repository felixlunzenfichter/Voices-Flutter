import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voices/models/user.dart';
import 'package:voices/models/message.dart';
import 'package:voices/constants.dart';
import 'package:voices/models/chat.dart';

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

  Stream<List<Chat>> getChatsStream({@required String loggedInUid}) {
    Stream<List<Chat>> chatStream = _fireStore
        .collection('chats')
        .where('uidsOfMembers', arrayContains: loggedInUid)
        .snapshots()
        .map((snap) => snap.documents.map((doc) {
              Chat chat = Chat.fromMap(map: doc.data);
              chat.chatId = doc.documentID;
              return chat;
            }).toList());
    return chatStream;
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

  Stream<List<Message>> getMessageStream({@required String chatId}) {
    try {
      var messageStream = _fireStore
          .collection('chats/$chatId/messages')
          .orderBy('timestamp')
          .snapshots()
          .map((snap) => snap.documents.reversed
              .map((doc) => Message.fromMap(map: doc.data))
              .toList());
      return messageStream;
    } catch (e) {
      print('Could not get the message stream because of error: $e');
    }
    return Stream.empty();
  }

  Future<void> addMessage(
      {@required String chatId, @required Message message}) async {
    try {
      message.timestamp = FieldValue.serverTimestamp();
      await _fireStore
          .collection("chats/$chatId/messages")
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

  //check if there is already a user in the users collection with the provided phonenumber and if not create one
  //if a new user has to be created execute whatToDoWhenUserNew with the new User as an Argument
  //if the user already exists execute whatToDoWhenUserAlreadyExists with the User as an Argument
  checkIfUserExists(
      {@required String phoneNumber,
      @required String uid,
      @required Function whatToDoWhenUserNew,
      @required Function whatToDoWhenUserAlreadyExists}) async {
    User user = await getUserWithPhoneNumber(phoneNumber: phoneNumber);

    if (user == null) {
      User newUser = User(
          uid: uid, phoneNumber: phoneNumber, imageUrl: kDefaultProfilePicUrl);
      await uploadUser(user: newUser);
      whatToDoWhenUserNew(newUser);
    } else {
      whatToDoWhenUserAlreadyExists(user);
    }
  }
}
