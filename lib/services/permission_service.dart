import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionStatus microphonePermissionStatus = PermissionStatus.undetermined;
  PermissionStatus speechRecognitionPermissionStatus =
      PermissionStatus.undetermined;

  PermissionService() {
    _initializeMicrophonePermission();
    _initializeSpeechRecognitionPermission();
  }

  askForMicrophonePermission() async {
    microphonePermissionStatus = await Permission.microphone.request();
  }

  askForSpeechRecognitionPermission() async {
    speechRecognitionPermissionStatus = await Permission.speech.request();
  }

  _initializeMicrophonePermission() async {
    microphonePermissionStatus = await Permission.microphone.status;
  }

  _initializeSpeechRecognitionPermission() async {
    speechRecognitionPermissionStatus = await Permission.speech.status;
  }
}
