import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  askForMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.request();
    switch (status) {
      case PermissionStatus.granted:
        // everything is alright already
        break;
      case PermissionStatus.denied:
        print("microphone permission denied");
        break;
      case PermissionStatus.permanentlyDenied:
        print("microphone permission permanently denied");
        // The user opted to never again see the permission request dialog for this
        // app. The only way to change the permission's status now is to let the
        // user manually enable it in the system settings.
        openAppSettings();
        break;
      case PermissionStatus.restricted:
        print("microphone permission restricted");

        break;
      case PermissionStatus.undetermined:
        print("microphone permission undetermined");
        break;
      default:
    }
  }

  askForSpeechRecognitionPermission() async {
    PermissionStatus status = await Permission.speech.request();
    switch (status) {
      case PermissionStatus.granted:
        // everything is alright already
        break;
      case PermissionStatus.denied:
        print("speech recognition permission denied");
        break;
      case PermissionStatus.permanentlyDenied:
        print("speech recognition permission permanently denied");
        // The user opted to never again see the permission request dialog for this
        // app. The only way to change the permission's status now is to let the
        // user manually enable it in the system settings.
        openAppSettings();
        break;
      case PermissionStatus.restricted:
        print("speech recognition permission restricted");
        break;
      case PermissionStatus.undetermined:
        print("speech recognition permission undetermined");
        break;
      default:
    }
  }
}
