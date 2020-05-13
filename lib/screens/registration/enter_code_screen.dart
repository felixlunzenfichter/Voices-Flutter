import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/registration/permissions_screen.dart';
import 'package:voices/screens/tabs_screen.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/models/user.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/services/permission_service.dart';

class EnterCodeScreen extends StatefulWidget {
  final String phoneNumber;

  EnterCodeScreen({@required this.phoneNumber});
  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  TextEditingController _textEditingController = TextEditingController();
  StreamController<ErrorAnimationType> _errorController;
  bool _wrongCodeEntered = false;
  String _enteredCode = "";
  bool _showSpinner = false;

  @override
  void initState() {
    _errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    _errorController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      progressIndicator: CupertinoActivityIndicator(),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.red),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: FlareActor(
                "assets/phone_verification.flr",
                animation: "otp",
                fit: BoxFit.fitHeight,
                alignment: Alignment.center,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Phone Number Verification',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: RichText(
                text: TextSpan(
                    text: "Enter the code sent to ",
                    children: [
                      TextSpan(
                          text: widget.phoneNumber,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                    style: TextStyle(color: Colors.black54, fontSize: 15)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
              child: PinCodeTextField(
                autoFocus: true,
                length: 6,
                obsecureText: false,
                textInputType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: Colors.red,
                  selectedColor: Colors.red,
                  inactiveColor: Colors.red,
                  disabledColor: Colors.red,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.red.shade100,
                  inactiveFillColor: Colors.red.shade300,
                ),
                animationDuration: Duration(milliseconds: 300),
                backgroundColor: Colors.white,
                enableActiveFill: true,
                errorAnimationController: _errorController,
                controller: _textEditingController,
                onCompleted: (v) {
                  _checkEnteredCode();
                },
                onChanged: (value) {
                  setState(() {
                    _enteredCode = value;
                  });
                },
                beforeTextPaste: (text) {
                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                  return true;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                _wrongCodeEntered
                    ? "*Please fill up all the cells properly"
                    : "",
                style: TextStyle(color: Colors.red.shade300, fontSize: 15),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
              child: Text("Clear"),
              onPressed: () {
                _textEditingController.clear();
              },
            )
          ],
        ),
      ),
    );
  }

  _checkEnteredCode() async {
    setState(() {
      _showSpinner = true;
    });
    final Function whatTodoWhenCodeCorrectForNewUser = (User newUser) async {
      final cloudFirestoreService =
          Provider.of<CloudFirestoreService>(context, listen: false);
      //we have to upload the user here so we have a user in the users collection even if he doesn't complete the registration process
      cloudFirestoreService.uploadUser(user: newUser);
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
          builder: (context) => PermissionsScreen(
            moveOnToNextRegistrationScreenAfter: true,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    };
    final Function whatTodoWhenCodeCorrectForExistingUser =
        (User existingUser) async {
      final permissionService =
          Provider.of<PermissionService>(context, listen: false);
      if (permissionService.areAllPermissionsGranted()) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => TabsScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => PermissionsScreen()),
          (Route<dynamic> route) => false,
        );
      }
    };

    final Function whatTodoWhenCodeFalse = () {
      _errorController.add(ErrorAnimationType.shake);
      _textEditingController.clear();
      setState(() {
        _showSpinner = false;
      });
    };

    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.checkEnteredCode(
        code: _enteredCode,
        whatTodoWhenCodeCorrectForNewUser: whatTodoWhenCodeCorrectForNewUser,
        whatTodoWhenCodeCorrectForExistingUser:
            whatTodoWhenCodeCorrectForExistingUser,
        whatTodoWhenCodeFalse: whatTodoWhenCodeFalse);
  }
}
