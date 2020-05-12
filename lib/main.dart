import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'screens/loading_login_or_tabs_screen.dart';
import 'package:voices/services/player_service.dart';
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

class Voices extends StatefulWidget {
  @override
  _VoicesState createState() => _VoicesState();
}

class _VoicesState extends State<Voices> {
  final authService = AuthService();
  final cloudFirestoreService = CloudFirestoreService();
  Stream<User> loggedInUserStream;
  ValueNotifier<bool> isFetchingNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _setLoggedInUserStream();
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
          catchError: (context, error) {
            print("error = ${error.toString()}");
            return null;
          },
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
        ChangeNotifierProvider<ValueNotifier<bool>>.value(
          value: isFetchingNotifier,
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
          home: LoadingLoginOrTabsScreen(),
        ),
      ),
    );
  }

  _setLoggedInUserStream() async {
    Stream<FirebaseUser> firebaseUserStream = authService.onAuthStateChanged();
    // Wait for new sign in or sign out
    await for (var firebaseUser in firebaseUserStream) {
      isFetchingNotifier.value = false;
      if (firebaseUser == null) {
        setState(() {
          loggedInUserStream = Stream.empty();
        });
      } else {
        setState(() {
          loggedInUserStream =
              cloudFirestoreService.getUserStream(uid: firebaseUser.uid);
        });
      }
    }
  }
}
