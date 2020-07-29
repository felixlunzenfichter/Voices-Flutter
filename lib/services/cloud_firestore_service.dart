import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voices/models/image_message.dart';
import 'package:voices/models/message.dart';
import 'package:voices/models/user.dart';
import 'package:voices/models/text_message.dart';
import 'package:voices/constants.dart';
import 'package:voices/models/Conversation.dart';
import 'package:voices/models/voice_message.dart';

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

  Future<User> getUserWithUid({@required String uid}) async {
    try {
      var userDocument =
          await _fireStore.collection('users').document(uid).get();
      return User.fromMap(map: userDocument.data);
    } catch (e) {
      print('Could not get user with uid = $uid because of error: $e');
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
      print(
          'Could not get user with phone number = $phoneNumber because of error: $e');
      return null;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      return (await _fireStore.collection('users').getDocuments())
          .documents
          .map((doc) => User.fromMap(map: doc.data))
          .toList();
    } catch (e) {
      print('Could not get users because of error: $e');
      return [];
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
      print('Could not get the user stream because of error: $e');
    }
    return Stream.empty();
  }

  Future<String> getChatWithUsers(
      {@required String uid1, @required String uid2}) async {
    try {
      List<Conversation> chats1 = (await _fireStore
              .collection('chats')
              .where('uidsOfMembers', arrayContains: uid1)
              .getDocuments())
          .documents
          .map((doc) => Conversation.fromMap(map: doc.data))
          .toList();
      List<Conversation> chats2 = (await _fireStore
              .collection('chats')
              .where('uidsOfMembers', arrayContains: uid2)
              .getDocuments())
          .documents
          .map((doc) => Conversation.fromMap(map: doc.data))
          .toList();

      List<Conversation> ConversationsOfBothUsers = chats1 + chats2;

      List<Conversation> chat12 = ConversationsOfBothUsers.where((chat) =>
          chat.uidsOfMembers.contains(uid1) &&
          chat.uidsOfMembers.contains(uid2)).toList();

      if (chat12.isNotEmpty) {
        return chat12[0].chatId;
      } else {
        //create chat and return chatId
        Conversation chat = await _createChat(uidsOfMembers: [uid1, uid2]);
        return chat.chatId;
      }
    } catch (e) {
      print('Could not get user because of error: $e');
      return null;
    }
  }

  Stream<List<Conversation>> getChatsStream({@required String loggedInUid}) {
    try {
      Stream<List<Conversation>> chatStream = _fireStore
          .collection('chats')
          .where('uidsOfMembers', arrayContains: loggedInUid)
          .snapshots()
          .map((snap) => snap.documents.map((doc) {
                Conversation chat = Conversation.fromMap(map: doc.data);
                chat.chatId = doc.documentID;
                return chat;
              }).toList());
      return chatStream;
    } catch (e) {
      print('Could not get the chats stream because of error: $e');
      return Stream.empty();
    }
  }

  Stream<List<Message>> getMessageStream({@required String chatId}) {
    try {
      var messageStream = _fireStore
          .collection('chats/$chatId/messages')
          .orderBy('timestamp', descending: true)

          /// Add the line below to limit the number of messages
//          .limit(3)
          .snapshots()
          .map((snap) => snap.documents.map((doc) {
                switch (doc.data['messageType']) {
                  case "MessageType.text":
                    return TextMessage.fromFirestore(doc: doc);
                  case "MessageType.voice":
                    return VoiceMessage.fromFirestore(doc: doc);
                  case "MessageType.image":
                    return ImageMessage.fromFirestore(doc: doc);
                  default:
                    return null;
                }
              }).toList());
      return messageStream;
    } catch (e) {
      print('Could not get the message stream because of error: $e');
      return Stream.empty();
    }
  }

  Future<void> addTextMessage(
      {@required String chatId, @required TextMessage textMessage}) async {
    try {
      Map<String, dynamic> messageMap = textMessage.toMap();
      messageMap
          .addEntries([MapEntry('timestamp', FieldValue.serverTimestamp())]);
      await _fireStore.collection("chats/$chatId/messages").add(messageMap);
    } catch (e) {
      print('Could not add text message because of error: $e');
    }
  }

  Future<void> addVoiceMessage(
      {@required String chatId, @required VoiceMessage voiceMessage}) async {
    try {
      Map<String, dynamic> messageMap = voiceMessage.toMap();
      messageMap
          .addEntries([MapEntry('timestamp', FieldValue.serverTimestamp())]);
      await _fireStore.collection("chats/$chatId/messages").add(messageMap);
    } catch (e) {
      print('Could not add voice message because of error: $e');
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
      print('Could not upload push token because of error: $e');
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
    try {
      User user = await getUserWithPhoneNumber(phoneNumber: phoneNumber);

      if (user == null) {
        User newUser = User(
            uid: uid,
            phoneNumber: phoneNumber,
            imageUrl: kDefaultProfilePicUrl);
        await uploadUser(user: newUser);
        whatToDoWhenUserNew(newUser);
      } else {
        whatToDoWhenUserAlreadyExists(user);
      }
    } catch (e) {
      print('Could not check if user exists because of error: $e');
    }
  }

  Future<Conversation> _createChat(
      {@required List<String> uidsOfMembers}) async {
    try {
      Conversation chat = Conversation(
        uidsOfMembers: uidsOfMembers,
        lastMessageText: 'No message yet',
      );
      Map<String, dynamic> chatMap = chat.toMap();
      chatMap.addEntries(
          [MapEntry("lastMessageTimestamp", FieldValue.serverTimestamp())]);
      var docReference = await _fireStore.collection('chats').add(chatMap);
      chat.chatId = docReference.documentID;
      await _fireStore
          .collection('chats')
          .document(chat.chatId)
          .updateData(chat.toMap());
      return chat;
    } catch (e) {
      print('Could not create chat because of error $e');
      return null;
    }
  }
}
