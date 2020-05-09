import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/models/user.dart';
import 'package:voices/shared_widgets/info_dialog.dart';
import 'package:voices/screens/navigation_screen.dart';
import 'create_profile_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flare_flutter/flare_actor.dart';

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
        backgroundColor: Colors.blue.shade50,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              children: <Widget>[
                SizedBox(height: 30),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 30),
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
                        activeFillColor: Colors.white,
                      ),
                      animationDuration: Duration(milliseconds: 300),
                      backgroundColor: Colors.blue.shade50,
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
                        print("Allowing to paste $text");
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return true;
                      },
                    )),
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
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Didn't receive the code? ",
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                      children: [
                        TextSpan(
                            text: " RESEND",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
                              },
                            style: TextStyle(
                                color: Color(0xFF91D3B3),
                                fontWeight: FontWeight.bold,
                                fontSize: 16))
                      ]),
                ),
                SizedBox(
                  height: 14,
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
        ),
      ),
    );
  }

  _checkEnteredCode() async {
    setState(() {
      _showSpinner = true;
    });
    final Function whatTodoWhenCodeCorrectForNewUser = (User newUser) async {
      setState(() {
        _showSpinner = false;
      });
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
            builder: (context) => CreateProfileScreen(user: newUser)),
        (Route<dynamic> route) => false,
      );
    };
    final Function whatTodoWhenCodeCorrectForExistingUser =
        (User existingUser) async {
      setState(() {
        _showSpinner = false;
      });
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => NavigationScreen()),
        (Route<dynamic> route) => false,
      );
    };

    final Function whatTodoWhenCodeFalse = () {
      _errorController.add(ErrorAnimationType.shake);
      _textEditingController.clear();
      setState(() {
        _showSpinner = false;
      });
      showInfoDialog(
          context: context,
          dialog: InfoDialog(title: "Code was wrong", text: "Please retry"));
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
