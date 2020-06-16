import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/permission_service.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;

  LifeCycleManager({this.child});

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    /// Register this widget as a binding observer. We will now receive state updates through didChangeAppLifecycleState.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final permissionService =
        Provider.of<PermissionService>(context, listen: false);
    switch (state) {
      case AppLifecycleState.resumed:
        //what to do if app came into foreground again
        permissionService.checkIfAllPermissionsGranted();
        break;
      case AppLifecycleState.inactive:
        //what to do if app is in foreground but can't respond to user input because of a phone call or so. App goes to inactive before going to pause.
        break;
      case AppLifecycleState.paused:
        //what to do if app went into background
        break;
      case AppLifecycleState.detached:
        //what to do if the flutter engine is still running but this widgets view doesn't exist
        break;
      default:
        print("this should never execute");
        break;
    }
  }

  @override
  void dispose() {

    /// Remove this widget from the list of active binding observers.
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
