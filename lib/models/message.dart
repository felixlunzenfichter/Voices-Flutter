abstract class Message {
  String messageId;
  String senderUid;
  DateTime timestamp;
  MessageType messageType;
}

enum MessageType { text, image, voice, directSend }
