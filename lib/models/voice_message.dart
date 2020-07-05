import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voices/models/message.dart';

/// This class encapsulates the meta data of a voice message stored in the cloud.
/// NB: This class does not contain the audio file itself.
class VoiceMessage extends Message {
  String downloadUrl;
  String transcript;
  Duration length;
  String firebasePath;

  VoiceMessage({
    String senderUid,
    DateTime timestamp,
    String downloadUrl,
    String transcript,
    Duration length,
    String firebasePath,
  }) {
    this.senderUid = senderUid;
    this.timestamp = timestamp;
    this.messageType = MessageType.voice;
    this.downloadUrl = downloadUrl;
    this.transcript = transcript;
    this.length = length;
    this.firebasePath = firebasePath;
  }

  VoiceMessage.fromFirestore({DocumentSnapshot doc}) {
    this.messageId = doc.documentID;
    Map<String, dynamic> map = doc.data;
    this.senderUid = map['senderUid'];
    this.timestamp = map['timestamp']?.toDate() ?? DateTime.now();
    this.messageType = MessageType.voice;
    this.downloadUrl = map['downloadUrl'];
    this.transcript = map['transcript'];
    this.length = Duration(milliseconds: map['length']);
    this.firebasePath = map['firebasePath'];
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'messageType': messageType.toString(),
      'downloadUrl': downloadUrl,
      'transcript': transcript,
      'length': length.inMilliseconds,
      'firebasePath': firebasePath,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ senderUid: $senderUid, ';
    toPrint += 'messageId: $messageId, ';
    toPrint += 'messageType: $messageType, ';
    toPrint += 'downloadUrl: $downloadUrl, ';
    toPrint += 'transcript: $transcript, ';
    toPrint += 'length: $length, ';
    toPrint += 'timestamp: ${timestamp.toString()} }\n';
    return toPrint;
  }
}
