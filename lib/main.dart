import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  bool _showPermissionScreen = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  @override
  Widget build(BuildContext context) {
    Widget screenToShow;
    if (authService.isFetching) {
      screenToShow = LoadingScreen();
    } else if (authService.loggedInUser == null) {
      screenToShow = LoginScreen();
    } else if (_showPermissionScreen) {
      screenToShow = PermissionsScreen();
    } else {
      screenToShow = TabsScreen();
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(
          value: authService,
        ),
        Provider<CloudFirestoreService>.value(
          value: cloudFirestoreService,
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

  _loadPermissions() async {
    await permissionService.initializeAllPermissions();
    if (!permissionService.areAllPermissionsGranted()) {
      setState(() {
        _showPermissionScreen = true;
      });
    }
  }
}
