import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voices/models/message.dart';

class ImageMessage extends Message {
  String downloadUrl;

  ImageMessage({
    String senderUid,
    DateTime timestamp,
    String downloadUrl,
  }) {
    this.senderUid = senderUid;
    this.timestamp = timestamp;
    this.messageType = MessageType.image;
    this.downloadUrl = downloadUrl;
  }

  ImageMessage.fromFirestore({DocumentSnapshot doc}) {
    this.messageId = doc.documentID;
    Map<String, dynamic> map = doc.data;
    this.senderUid = map['senderUid'];
    this.timestamp = map['timestamp']?.toDate() ?? DateTime.now();
    this.messageType = MessageType.image;
    this.downloadUrl = map['downloadUrl'];
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'messageType': messageType.toString(),
      'downloadUrl': downloadUrl,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ senderUid: $senderUid, ';
    toPrint += 'messageId: $messageId, ';
    toPrint += 'messageType: $messageType, ';
    toPrint += 'downloadUrl: $downloadUrl, ';
    toPrint += 'timestamp: ${timestamp.toString()} }\n';
    return toPrint;
  }
}
