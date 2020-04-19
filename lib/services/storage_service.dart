import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final StorageReference _storageReference = FirebaseStorage().ref();

  Future<String> uploadProfilePic(
      {@required String fileName, @required File image}) async {
    try {
      final StorageUploadTask uploadTask =
          _storageReference.child('profile_pictures/$fileName').putFile(image);
      StorageTaskSnapshot snap = await uploadTask.onComplete;
      String downloadUrl = await snap.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Could not upload profile picture');
      print(e);
      return null;
    }
  }
}
