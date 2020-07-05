import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voices/models/message.dart';
import 'package:voices/models/voice_message.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

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
      print('Could not upload profile picture with fileName = $fileName');
      print(e);
      return null;
    }
  }

  /// Upload [audioFile] to the permanent cloud storage to position [firebasePath].
  Future<String> uploadAudioFile(
      {@required String firebasePath, @required File audioFile}) async {
    try {
      final StorageUploadTask uploadTask =
          _storageReference.child(firebasePath).putFile(audioFile);
      StorageTaskSnapshot snap = await uploadTask.onComplete;
      String downloadUrl = await snap.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Could not upload audio file with path = $firebasePath');
      print(e);
      return null;
    }
  }

  /// Todo: implement
  Future<File> downloadAudioFile({@required VoiceMessage voiceMessage}) async {
//    String downloadURL = voiceMessage.downloadUrl;

    /// get storage reference.
    String firebasePath = voiceMessage.firebasePath;
    print(firebasePath);
    StorageReference ref = FirebaseStorage().ref().child(firebasePath);

    /// Download data.
    String downloadURL = await ref.getDownloadURL();
    http.Response downloadData = await http.get(downloadURL);

    /// Create local file.
    final String uuid = Uuid().v1();
    final Directory systemTempDir = Directory.systemTemp;

    /// Todo: .txt is not what we want here right?
    final File audioFile = File('${systemTempDir.path}/tmp$uuid.mp3');
    if (audioFile.existsSync()) {
      await audioFile.delete();
    }
    await audioFile.create();
    assert(await audioFile.readAsString() == "");

    final StorageFileDownloadTask task = ref.writeToFile(audioFile);

    final int byteCount = (await task.future).totalByteCount;
    final Uint8List tempFileContents = await audioFile.readAsBytes();

    final String fileContents = downloadData.body;
    final String name = await ref.getName();
    final String bucket = await ref.getBucket();
    final String path = await ref.getPath();
    print(
        'Success!\n Downloaded $name \n from url: $downloadURL @ bucket: $bucket\n '
        'at path: $path \n\nFile contents: "$fileContents" \n'
        'Wrote "$tempFileContents" to tmp.txt');

    return audioFile;
  }
}
