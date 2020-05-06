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
    this.senderUid = senderUid;
    this.timestamp = timestamp;
    this.messageType = MessageType.directSend;
    this.downloadUrlsOfChunks = downloadUrlsOfChunks;
    this.totalLength = totalLength;
  }

  DirectSendMessage.fromMap({Map<String, dynamic> map}) {
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
    toPrint += 'messageType: $messageType, ';
    toPrint += 'downloadUrlsOfChunks: $downloadUrlsOfChunks, ';
    toPrint += 'totalLength: $totalLength, ';
    toPrint += 'timestamp: ${timestamp.toString()} }\n';
    return toPrint;
  }
}
