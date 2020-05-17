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

  /// This app is designed only to work vertically, thence we limit orientations to portrait up and down.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  /// Make sure the glue between the flutter engine and the widget layer is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  return runApp(Voices());
}

class Voices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    /// Global state management layer.
    return MultiProvider(
      providers: [

        /// User authentication service.
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),

        /// Cloud service for real time data.
        Provider<CloudFirestoreService>(
          create: (_) => CloudFirestoreService(),
        ),

        /// Permanent storage.
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),

        /// Record audio.
        ChangeNotifierProvider<RecorderService>(
          create: (_) => RecorderService(),
        ),

        /// Play audio from local storage.
        Provider<LocalPlayerService>(
          create: (_) => LocalPlayerService(),
        ),

        /// Play audio from the cloud.
        Provider<CloudPlayerService>(
          create: (_) => CloudPlayerService(),
        ),

        /// Handle permission.
        ChangeNotifierProvider<PermissionService>(
          create: (_) => PermissionService(),
        ),

        /// Audio file format conversion.
        Provider<FileConverterService>(
          create: (_) => FileConverterService(),
        ),

        /// Convert speech to text.
        ChangeNotifierProvider<SpeechToTextService>(
          create: (_) => SpeechToTextService(),
        ),
      ],

      /// Detect gestures.
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
