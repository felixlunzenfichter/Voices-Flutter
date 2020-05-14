import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voices/models/message.dart';

class DirectSendMessage extends Message {
  List<String> downloadUrlsOfChunks;
  Duration totalLength;

  DirectSendMessage({
    String senderUid,
    String text,
    DateTime timestamp,
    List<String> downloadUrlsOfChunks,
    Duration totalLength,
  }) {
    this.messageId = messageId;
    this.senderUid = senderUid;
    this.timestamp = timestamp;
    this.messageType = MessageType.directSend;
    this.downloadUrlsOfChunks = downloadUrlsOfChunks;
    this.totalLength = totalLength;
  }

  DirectSendMessage.fromFirestore({DocumentSnapshot doc}) {
    this.messageId = doc.documentID;
    Map<String, dynamic> map = doc.data;
    this.senderUid = map['senderUid'];
    this.timestamp = map['timestamp']?.toDate() ?? DateTime.now();
    this.messageType = MessageType.directSend;
    //todo convert firebase list to dart list
    this.downloadUrlsOfChunks = map['downloadUrlsOfChunks'];
    this.totalLength = Duration(milliseconds: map['totalLength']);
  }

  toMap() {
    return {
      'senderUid': senderUid,
      'messageType': messageType,
      'downloadUrlsOfChunks': downloadUrlsOfChunks,
      'totalLength': totalLength.inMilliseconds,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ senderUid: $senderUid, ';
    toPrint += 'messageId: $messageId, ';
    toPrint += 'messageType: $messageType, ';
    toPrint += 'downloadUrlsOfChunks: $downloadUrlsOfChunks, ';
    toPrint += 'totalLength: $totalLength, ';
    toPrint += 'timestamp: ${timestamp.toString()} }\n';
    return toPrint;
  }
}
