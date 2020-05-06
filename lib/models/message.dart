abstract class Message {
  String senderUid;
  DateTime timestamp;
  MessageType messageType;
}

enum MessageType { text, image, voice, directSend }
