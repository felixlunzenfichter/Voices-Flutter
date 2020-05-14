import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voices/models/message.dart';

class TextMessage extends Message {
  String text;

  TextMessage({
    String senderUid,
    String text,
    DateTime timestamp,
  }) {
    this.senderUid = senderUid;
    this.timestamp = timestamp;
    this.messageType = MessageType.text;
    this.text = text;
  }

  TextMessage.fromFirestore({DocumentSnapshot doc}) {
    this.messageId = doc.documentID;
    Map<String, dynamic> map = doc.data;
    this.senderUid = map['senderUid'];
    this.timestamp = map['timestamp']?.toDate() ?? DateTime.now();
    this.messageType = MessageType.text;
    this.text = map['text'];
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'messageType': messageType.toString(),
      'text': text,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ text: $text, ';
    toPrint += 'senderUid: $senderUid, ';
    toPrint += 'messageType: $messageType, ';
    toPrint += 'timestamp: ${timestamp.toString()} }\n';
    return toPrint;
  }
}
