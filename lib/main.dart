import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/services/player_service.dart';
import 'package:voices/services/recorder_service.dart';
import 'package:voices/services/permission_service.dart';
import 'services/auth_service.dart';
import 'services/cloud_firestore_service.dart';
import 'services/storage_service.dart';
import 'services/speech_to_text_service.dart';
import 'services/file_converter_service.dart';
import 'screens/navigation_screen.dart';

void main() async {
  // This app is designed only to work vertically, so we limit
  // orientations to portrait up and down.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  return runApp(Voices());
}

class Voices extends StatefulWidget {
  @override
  _VoicesState createState() => _VoicesState();
}

class _VoicesState extends State<Voices> {
  final authService = AuthService();
  final cloudFirestoreService = CloudFirestoreService();
  Stream<User> loggedInUserStream;

  @override
  void initState() {
    super.initState();
    loggedInUserStream = _getLoggedInUserStream().distinct();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(
          value: authService,
        ),
        Provider<CloudFirestoreService>.value(
          value: cloudFirestoreService,
        ),
        StreamProvider.value(
          value: loggedInUserStream,
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        ChangeNotifierProvider<RecorderService>(
          create: (_) => RecorderService(),
        ),
        ChangeNotifierProvider<PlayerService>(
          create: (_) => PlayerService(),
        ),
        Provider<PermissionService>(
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
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
          ),
          home: NavigationScreen(),
        ),
      ),
    );
  }

  Stream<User> _getLoggedInUserStream() async* {
    Stream<FirebaseUser> firebaseUserStream = authService.onAuthStateChanged();
    // Wait until a new firebase user is available
    await for (var firebaseUser in firebaseUserStream) {
      if (firebaseUser == null) {
        yield null;
      } else {
        User user =
            await cloudFirestoreService.getUserWithUid(uid: firebaseUser.uid);
        yield user; // Add the new user to the user stream
      }
    }
  }
}
