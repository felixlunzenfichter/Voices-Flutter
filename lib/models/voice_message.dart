import 'package:voices/models/message.dart';

class VoiceMessage extends Message {
  String downloadUrl;
  String transcript;
  Duration length;

  VoiceMessage({
    String senderUid,
    String text,
    DateTime timestamp,
    String downloadUrl,
    String transcript,
    Duration length,
  }) {
    this.senderUid = senderUid;
    this.timestamp = timestamp;
    this.messageType = MessageType.voice;
    this.downloadUrl = downloadUrl;
    this.transcript = transcript;
    this.length = length;
  }

  VoiceMessage.fromMap({Map<String, dynamic> map}) {
    this.senderUid = map['senderUid'];
    this.timestamp = map['timestamp']?.toDate() ?? DateTime.now();
    this.messageType = MessageType.voice;
    this.downloadUrl = map['downloadUrl'];
    this.transcript = map['transcript'];
    this.length = Duration(milliseconds: map['length']);
  }

  toMap() {
    return {
      'senderUid': senderUid,
      'messageType': messageType,
      'downloadUrl': downloadUrl,
      'transcript': transcript,
      'length': length.inMilliseconds,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ senderUid: $senderUid, ';
    toPrint += 'messageType: $messageType, ';
    toPrint += 'downloadUrl: $downloadUrl, ';
    toPrint += 'transcript: $transcript, ';
    toPrint += 'length: $length, ';
    toPrint += 'timestamp: ${timestamp.toString()} }\n';
    return toPrint;
  }
}
