import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voices/lifecycle_manager.dart';
import 'package:voices/screens/loading_screen.dart';
import 'package:voices/screens/registration/login_screen.dart';
import 'package:voices/screens/registration/permissions_screen.dart';
import 'package:voices/screens/tabs_screen.dart';
import 'package:voices/services/cloud_player_service.dart';
import 'services/local_player_service.dart';
import 'package:voices/services/recorder_service.dart';
import 'package:voices/services/permission_service.dart';
import 'services/auth_service.dart';
import 'services/cloud_firestore_service.dart';
import 'services/storage_service.dart';
import 'services/speech_to_text_service.dart';
import 'services/file_converter_service.dart';

void main() async {
  // This app is designed only to work vertically, so we limit
  // orientations to portrait up and down.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  return runApp(Voices());
}

class Voices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(), //(_) stands for (context)
        ),
        Provider<CloudFirestoreService>(
          create: (_) => CloudFirestoreService(),
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        Provider<RecorderService>(
          create: (_) => RecorderService(),
          dispose: (context, value) => value.releaseRecorder(),
        ),
        Provider<LocalPlayerService>(
          create: (_) => LocalPlayerService(),
        ),
        Provider<CloudPlayerService>(
          create: (_) => CloudPlayerService(),
        ),
        ChangeNotifierProvider<PermissionService>(
          create: (_) => PermissionService(),
        ),
        Provider<FileConverterService>(
          create: (_) => FileConverterService(),
        ),
        ChangeNotifierProvider<SpeechToTextService>(
          create: (_) => SpeechToTextService(),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: LifeCycleManager(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
            ),
            home: ScreenToShow(),
          ),
        ),
      ),
    );
  }
}

class ScreenToShow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final permissionService = Provider.of<PermissionService>(context);

    if (authService.isFetching) {
      return LoadingScreen();
    } else if (authService.loggedInUser == null) {
      return LoginScreen();
    } else if (!permissionService.areAllPermissionsGranted) {
      return PermissionsScreen();
    } else {
      return TabsScreen();
    }
  }
}
