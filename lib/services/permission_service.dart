import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionStatus microphonePermissionStatus = PermissionStatus.undetermined;
  PermissionStatus speechRecognitionPermissionStatus =
      PermissionStatus.undetermined;
  PermissionStatus contactsPermissionStatus = PermissionStatus.undetermined;
  PermissionStatus cameraPermissionStatus = PermissionStatus.undetermined;
  PermissionStatus photosPermissionStatus = PermissionStatus.undetermined;

  PermissionService() {
    _initializeAllPermissions();
  }

  askForMicrophonePermission() async {
    microphonePermissionStatus = await Permission.microphone.request();
  }

  askForSpeechRecognitionPermission() async {
    speechRecognitionPermissionStatus = await Permission.speech.request();
  }

  askForContactsPermission() async {
    contactsPermissionStatus = await Permission.contacts.request();
  }

  askForCameraPermission() async {
    cameraPermissionStatus = await Permission.camera.request();
  }

  askForPhotosPermission() async {
    photosPermissionStatus = await Permission.photos.request();
  }

  _initializeAllPermissions() async {
    microphonePermissionStatus = await Permission.microphone.status;
    speechRecognitionPermissionStatus = await Permission.speech.status;
    contactsPermissionStatus = await Permission.contacts.status;
    cameraPermissionStatus = await Permission.camera.status;
    photosPermissionStatus = await Permission.photos.status;
  }
}
