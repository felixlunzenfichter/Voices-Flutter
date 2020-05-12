import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:voices/screens/loading_screen.dart';
import 'package:voices/screens/registration/login_screen.dart';
import 'package:voices/screens/registration/permissions_screen.dart';
import 'package:voices/screens/tabs_screen.dart';
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
  final permissionService = PermissionService();
  Stream<User> get loggedInUserStream => _loggedInUserStreamController.stream
      .asBroadcastStream(); //the stream of the currently logged in user that is provided to the rest of the app
  final _loggedInUserStreamController = StreamController<User>();
  Stream<User>
      _fireStoreStream; //the stream of the currently logged in user directly from firestore (that is reset whenever the authentication stream spits out a new value)
  StreamSubscription<User> _fireStoreStreamSubscription;
  bool _isFetching = true;
  bool _isLoggedIn = false;
  bool _showPermissionScreen = false;

  @override
  void initState() {
    super.initState();
    _createLoggedInUserStream();
    _loadPermissions();
  }

  @override
  void dispose() {
    _fireStoreStreamSubscription.cancel();
    _loggedInUserStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("_isFetching = $_isFetching");
    print("_isLoggedIn = $_isLoggedIn");
    print("_showPermissionScreen = $_showPermissionScreen");
    Widget screenToShow;
    if (_isFetching) {
      screenToShow = LoadingScreen();
    } else if (!_isLoggedIn) {
      screenToShow = LoginScreen();
    } else if (_showPermissionScreen) {
      screenToShow = PermissionsScreen();
    } else {
      screenToShow = TabsScreen();
    }

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(
          value: authService,
        ),
        Provider<CloudFirestoreService>.value(
          value: cloudFirestoreService,
        ),
        StreamProvider<User>.value(
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
        Provider<PermissionService>.value(
          value: permissionService,
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
          home: screenToShow,
        ),
      ),
    );
  }

  _createLoggedInUserStream() async {
    Stream<FirebaseUser> authenticationStream =
        authService.onAuthStateChanged();
    // Wait for new sign in or sign out
    await for (var firebaseUser in authenticationStream) {
      //firebaseUser == null means the user signed out and firebaseUser != null means the user just signed in
      if (firebaseUser == null) {
        //let the rest of the app know that the user logged out
        _loggedInUserStreamController.sink.add(null);
        setState(() {
          _isFetching = false;
          _isLoggedIn = false;
        });
      } else {
        //get the stream for the new user
        _fireStoreStream =
            cloudFirestoreService.getUserStream(uid: firebaseUser.uid);
        //listen to the new stream and pass the new values on to the loggedInUserStream
        _fireStoreStreamSubscription = _fireStoreStream.listen((user) {
          _loggedInUserStreamController.sink.add(user);
        }, onError: (error) {
          print(error);
        }, cancelOnError: false);
        _waitForFirstUserAsync();
      }
    }
  }

  _waitForFirstUserAsync() async {
    await loggedInUserStream.first;
    setState(() {
      _isFetching = false;
      _isLoggedIn = true;
    });
  }

  _loadPermissions() async {
    await permissionService.initializeAllPermissions();
    if (!permissionService.areAllPermissionsGranted()) {
      setState(() {
        _showPermissionScreen = true;
      });
    }
  }
}
