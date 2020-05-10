import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voices/models/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:voices/screens/tabs_or_permissions_screen.dart';
import 'package:voices/shared_widgets/next_button.dart';
import 'create_profile_screen.dart';

import 'package:voices/screens/registration/enter_code_screen.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/shared_widgets/info_dialog.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:voices/services/cloud_firestore_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showSpinner = false;
  String _enteredNumber = '';
  String _selectedDialCode = "+41";

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      progressIndicator: CupertinoActivityIndicator(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 200.0,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Image.asset('assets/logo.png'),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: <Widget>[
                        CountryCodePicker(
                          onChanged: _onCountryChange,
                          initialSelection: '+41',
                          alignLeft: false,
                        ),
                        Expanded(
                          child: CupertinoTextField(
                            placeholder: 'Enter your phone number',
                            keyboardType: TextInputType.number,
                            onChanged: (newNumber) {
                              _enteredNumber = newNumber.trim();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              NextButton(
                text: "Verify",
                onPressed: _verifyPhoneNumber,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    _selectedDialCode = countryCode.dialCode;
  }

  _verifyPhoneNumber() async {
    setState(() {
      _showSpinner = true;
    });

    final Function whatTodoWhenNewUserVerified = (User newUser) async {
      final cloudFirestoreService =
          Provider.of<CloudFirestoreService>(context, listen: false);
      //we have to upload the user here so we have a user in the users collection even if he doesn't complete the registration process
      cloudFirestoreService.uploadUser(user: newUser);
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
            builder: (context) => CreateProfileScreen(user: newUser)),
        (Route<dynamic> route) => false,
      );
    };

    final Function whatTodoWhenExistingUserVerified =
        (User existingUser) async {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => TabsOrPermissionsScreen()),
        (Route<dynamic> route) => false,
      );
    };

    final Function whatTodoWhenVerificationFailed = (String errorMessage) {
      setState(() {
        _showSpinner = false;
      });
      showInfoDialog(
          context: context,
          dialog: InfoDialog(title: "Verification failed", text: errorMessage));
    };

    final Function whatTodoWhenSmsSent = () {
      setState(() {
        _showSpinner = false;
      });
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => EnterCodeScreen(
                phoneNumber: _selectedDialCode + _enteredNumber,
              )));
    };
    final authService = Provider.of<AuthService>(context, listen: false);
    final phoneNumber = _selectedDialCode + _enteredNumber;
    await authService.verifyPhoneNumberAutomaticallyOrSendCode(
        phoneNumber: phoneNumber,
        whatTodoWhenNewUserVerified: whatTodoWhenNewUserVerified,
        whatTodoWhenExistingUserVerified: whatTodoWhenExistingUserVerified,
        whatTodoWhenVerificationFailed: whatTodoWhenVerificationFailed,
        whatTodoWhenSmsSent: whatTodoWhenSmsSent);
  }
}
