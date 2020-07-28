import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voices/lifecycle_manager.dart';
import 'package:voices/screens/loading_screen.dart';
import 'package:voices/screens/registration/login_screen.dart';
import 'package:voices/screens/registration/permissions_screen.dart';
import 'package:voices/screens/tabs_screen.dart';
import 'package:voices/services/recorder_service.dart';
import 'services/local_player_service.dart';
import 'package:voices/services/permission_service.dart';
import 'services/logged_in_user_service.dart';
import 'services/cloud_firestore_service.dart';
import 'services/cloud_storage_service.dart';
import 'services/speech_to_text_service.dart';
import 'services/file_converter_service.dart';

void main() async {
  /// Make sure the glue between the flutter engine and the widget layer is initialized.
  WidgetsFlutterBinding.ensureInitialized();
//  TestWidgetsFlutterBinding.ensureInitialized();

  /// This app is designed only to work vertically, thence we limit orientations to portrait up and down.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  return runApp(Voices());
}

class Voices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// Global state management layer.
    return MultiProvider(
      providers: [
//        ChangeNotifierProvider<CurrentlyListeningInChatState>(
//          create: (_) => CurrentlyListeningInChatState(),
//        ),

        /// User authentication service.
        ChangeNotifierProvider<LoggedInUserService>(
          create: (_) => LoggedInUserService(),
        ),

        /// Cloud service for real time data.
        Provider<CloudFirestoreService>(
          create: (_) => CloudFirestoreService(),
        ),

        /// Permanent storage.
        Provider<CloudStorageService>(
          create: (_) => CloudStorageService(),
        ),

        /// Record audio. Todo: remove.
        ChangeNotifierProvider<RecorderService>(
          create: (_) => RecorderService(),
        ),

        /// Play audio from local storage.
        ChangeNotifierProvider<LocalPlayerService>(
          create: (_) => LocalPlayerService(),
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

      /// Remove the keyboard by taping on the screen.
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },

        /// Manage the lifecycle of the app.
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

/// Navigate the user through permission and login screen before the main app can be used.
class ScreenToShow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<LoggedInUserService>(context);
    final permissionService = Provider.of<PermissionService>(context);

    /// Show a loading screen while we are verifying whether the user is logged in.
    if (authService.isFetching) {
      return LoadingScreen();

      /// A null value for the currently logged in user reflects the fact that no one is logged in on this device. Thus we show the login screen.
    } else if (authService.loggedInUser == null) {
      return LoginScreen();

      /// All required permissions need to be granted before the user can proceed from this scream.
    } else if (!permissionService.areAllPermissionsGranted) {
      return PermissionsScreen();

      /// Start the main application.
    } else {
      return TabsScreen();
    }
  }
}
