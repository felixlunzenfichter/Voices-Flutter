import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService with ChangeNotifier {
  bool areAllPermissionsGranted = false;
  PermissionStatus microphonePermissionStatus = PermissionStatus.undetermined;
  PermissionStatus speechRecognitionPermissionStatus =
      PermissionStatus.undetermined;
  PermissionStatus contactsPermissionStatus = PermissionStatus.undetermined;
  PermissionStatus cameraPermissionStatus = PermissionStatus.undetermined;
  PermissionStatus photosPermissionStatus = PermissionStatus.undetermined;
  PermissionStatus storagePermissionStatus = PermissionStatus.undetermined;

  PermissionService() {
    initializeAllPermissions();
  }

  initializeAllPermissions() async {
    List<Future<PermissionStatus>> futures = [
      Permission.microphone.status,
      Permission.speech.status,
      Permission.contacts.status,
      Permission.camera.status,
      Permission.photos.status,
      Permission.storage.status
    ];
    List<PermissionStatus> statuses = await Future.wait(futures);
    microphonePermissionStatus = statuses[0];
    speechRecognitionPermissionStatus = statuses[1];
    contactsPermissionStatus = statuses[2];
    cameraPermissionStatus = statuses[3];
    photosPermissionStatus = statuses[4];
    storagePermissionStatus = statuses[5];
    checkIfAllPermissionsGranted();
  }

  askForAllPermissions() async {
    microphonePermissionStatus = await Permission.microphone.request();
    speechRecognitionPermissionStatus = await Permission.speech.request();
    contactsPermissionStatus = await Permission.contacts.request();
    cameraPermissionStatus = await Permission.camera.request();
    photosPermissionStatus = await Permission.photos.request();
    storagePermissionStatus = await Permission.storage.request();
  }

  List<OurPermission> getNotGrantedPermissions() {
    List<OurPermission> notGrantedPermissions = [];
    if (microphonePermissionStatus != PermissionStatus.granted) {
      notGrantedPermissions.add(OurPermission(type: PermissionType.microphone));
    }
    if (speechRecognitionPermissionStatus != PermissionStatus.granted) {
      notGrantedPermissions.add(OurPermission(type: PermissionType.speech));
    }
    if (contactsPermissionStatus != PermissionStatus.granted) {
      notGrantedPermissions.add(OurPermission(type: PermissionType.contacts));
    }
    if (cameraPermissionStatus != PermissionStatus.granted) {
      notGrantedPermissions.add(OurPermission(type: PermissionType.camera));
    }
    if (photosPermissionStatus != PermissionStatus.granted) {
      notGrantedPermissions.add(OurPermission(type: PermissionType.photos));
    }
    if (storagePermissionStatus != PermissionStatus.granted) {
      notGrantedPermissions.add(OurPermission(type: PermissionType.storage));
    }
    return notGrantedPermissions;
  }

  checkIfAllPermissionsGranted() {
    if (microphonePermissionStatus == PermissionStatus.granted &&
        speechRecognitionPermissionStatus == PermissionStatus.granted &&
        contactsPermissionStatus == PermissionStatus.granted &&
        cameraPermissionStatus == PermissionStatus.granted &&
        photosPermissionStatus == PermissionStatus.granted &&
        storagePermissionStatus == PermissionStatus.granted) {
      areAllPermissionsGranted = true;
    } else {
      areAllPermissionsGranted = false;
    }
    notifyListeners();
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
      case PermissionType.storage:
        return "storage access";
      default:
        return "unknown permission";
    }
  }
}

enum PermissionType { microphone, speech, contacts, camera, photos, storage }
