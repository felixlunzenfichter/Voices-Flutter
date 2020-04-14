///commented out for development purposes
//
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:modal_progress_hud/modal_progress_hud.dart';
//import 'package:provider/provider.dart';
//import 'package:voices/services/auth_service.dart';
//import 'package:voices/models/user.dart';
//import 'package:voices/shared%20widgets/info_dialog.dart';
//import 'navigation_screen.dart';
//import 'create_profile_screen.dart';
//
//class EnterCodeScreen extends StatefulWidget {
//  @override
//  _EnterCodeScreenState createState() => _EnterCodeScreenState();
//}
//
//class _EnterCodeScreenState extends State<EnterCodeScreen> {
//  String _smsCode;
//  bool _showSpinner = false;
//
//  @override
//  Widget build(BuildContext context) {
//    return ModalProgressHUD(
//      inAsyncCall: _showSpinner,
//      progressIndicator: CupertinoActivityIndicator(),
//      child: Scaffold(
//        appBar: AppBar(
//          title: Text('Enter Code'),
//        ),
//        backgroundColor: Colors.green,
//        body: Column(
//          children: <Widget>[
//            CupertinoTextField(
//              placeholder: 'Enter the code here',
//              maxLength: 6,
//              keyboardType: TextInputType.number,
//              onChanged: (newCode) {
//                _smsCode = newCode;
//                if (newCode.length == 6) {
//                  _checkEnteredCode();
//                }
//              },
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//
//  _checkEnteredCode() async {
//    setState(() {
//      _showSpinner = true;
//    });
//    final Function whatTodoWhenCodeCorrectForNewUser = (User newUser) async {
//      setState(() {
//        _showSpinner = false;
//      });
//      Navigator.of(context).pushAndRemoveUntil(
//        CupertinoPageRoute(
//            builder: (context) => CreateProfileScreen(user: newUser)),
//        (Route<dynamic> route) => false,
//      );
//    };
//    final Function whatTodoWhenCodeCorrectForExistingUser =
//        (User existingUser) async {
//      setState(() {
//        _showSpinner = false;
//      });
//      Navigator.of(context).pushAndRemoveUntil(
//        CupertinoPageRoute(builder: (context) => NavigationScreen()),
//        (Route<dynamic> route) => false,
//      );
//    };
//
//    final Function whatTodoWhenCodeFalse = () {
//      setState(() {
//        _showSpinner = false;
//        _smsCode = "";
//      });
//      showInfoDialog(
//          context: context,
//          dialog: InfoDialog(title: "Code was wrong", text: "Please retry"));
//    };
//
//    final authService = Provider.of<AuthService>(context, listen: false);
//    await authService.checkEnteredCode(
//        code: _smsCode,
//        whatTodoWhenCodeCorrectForNewUser: whatTodoWhenCodeCorrectForNewUser,
//        whatTodoWhenCodeCorrectForExistingUser:
//            whatTodoWhenCodeCorrectForExistingUser,
//        whatTodoWhenCodeFalse: whatTodoWhenCodeFalse);
//  }
//}
