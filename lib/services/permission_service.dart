import 'package:flutter/foundation.dart';
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

  askForAllPermissions() async {
    microphonePermissionStatus = await Permission.microphone.request();
    speechRecognitionPermissionStatus = await Permission.speech.request();
    contactsPermissionStatus = await Permission.contacts.request();
    cameraPermissionStatus = await Permission.camera.request();
    photosPermissionStatus = await Permission.photos.request();
  }

  List<OurPermission> getDeniedPermissions() {
    List<OurPermission> deniedPermissions = [];
    if (microphonePermissionStatus == PermissionStatus.denied) {
      deniedPermissions.add(OurPermission(type: PermissionType.microphone));
    }
    if (speechRecognitionPermissionStatus == PermissionStatus.denied) {
      deniedPermissions.add(OurPermission(type: PermissionType.speech));
    }
    if (contactsPermissionStatus == PermissionStatus.denied) {
      deniedPermissions.add(OurPermission(type: PermissionType.contacts));
    }
    if (cameraPermissionStatus == PermissionStatus.denied) {
      deniedPermissions.add(OurPermission(type: PermissionType.camera));
    }
    if (photosPermissionStatus == PermissionStatus.denied) {
      deniedPermissions.add(OurPermission(type: PermissionType.photos));
    }
    return deniedPermissions;
  }

  List<OurPermission> getPermanentlyDeniedPermissions() {
    List<OurPermission> permanentlyDeniedPermissions = [];
    if (microphonePermissionStatus == PermissionStatus.permanentlyDenied) {
      permanentlyDeniedPermissions
          .add(OurPermission(type: PermissionType.microphone));
    }
    if (speechRecognitionPermissionStatus ==
        PermissionStatus.permanentlyDenied) {
      permanentlyDeniedPermissions
          .add(OurPermission(type: PermissionType.speech));
    }
    if (contactsPermissionStatus == PermissionStatus.permanentlyDenied) {
      permanentlyDeniedPermissions
          .add(OurPermission(type: PermissionType.contacts));
    }
    if (cameraPermissionStatus == PermissionStatus.permanentlyDenied) {
      permanentlyDeniedPermissions
          .add(OurPermission(type: PermissionType.camera));
    }
    if (photosPermissionStatus == PermissionStatus.permanentlyDenied) {
      permanentlyDeniedPermissions
          .add(OurPermission(type: PermissionType.photos));
    }
    return permanentlyDeniedPermissions;
  }

  _initializeAllPermissions() async {
    microphonePermissionStatus = await Permission.microphone.status;
    speechRecognitionPermissionStatus = await Permission.speech.status;
    contactsPermissionStatus = await Permission.contacts.status;
    cameraPermissionStatus = await Permission.camera.status;
    photosPermissionStatus = await Permission.photos.status;
  }
}

class OurPermission {
  PermissionType type;

  OurPermission({@required this.type});

  @override
  String toString() {
    switch (type) {
      case PermissionType.microphone:
        return "microphone usage";
      case PermissionType.speech:
        return "speech recognition";
      case PermissionType.contacts:
        return "contacts access";
      case PermissionType.camera:
        return "camera access";
      case PermissionType.photos:
        return "photos access";
      default:
        return "unknown permission";
    }
  }
}

enum PermissionType { microphone, speech, contacts, camera, photos }
