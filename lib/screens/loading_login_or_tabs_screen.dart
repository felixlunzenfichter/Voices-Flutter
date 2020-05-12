import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voices/models/user.dart';
import 'package:voices/screens/tabs_or_permissions_screen.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/registration/login_screen.dart';

class LoadingLoginOrTabsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isFetchingNotifier = Provider.of<ValueNotifier<bool>>(context);
    final loggedInUser = Provider.of<User>(context, listen: false);

    if (isFetchingNotifier.value) {
      //we are still fetching the loggedInUser
      //show loading screen
      return Scaffold(
        body: CupertinoActivityIndicator(),
      );
    } else {
      //we are done fetching
      if (loggedInUser == null) {
        return LoginScreen();
      } else {
        return TabsOrPermissionsScreen();
      }
    }
  }
}
