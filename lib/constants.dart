import 'package:path_provider/path_provider.dart';

const String kDefaultProfilePicUrl =
    "https://firebasestorage.googleapis.com/v0/b/voices-dev1.appspot.com/o/default_profile_pic.jpg?alt=media&token=1a4a729e-cc6e-4ab0-8fab-cf982c840257";

/// Recording tool

double kRecordingVisualheight = 100;

/// In order to set the constant [klocalPath] we have this little workaround.
/// I think it can't be a constant because [getApplicationDocumentsDirectory] returns a [Future].
/// We treat it like a constant though.
class LocalDirectory {
  String localDirectoryPath;

  LocalDirectory() {
    setLocalPath();
  }

  void setLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    localDirectoryPath = directory.path;
  }
}

LocalDirectory localDirectory = LocalDirectory();
String kLocalPath = localDirectory.localDirectoryPath;
