import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final Function onPressed;
  final String text;

  NextButton({@required this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.redAccent,
      borderRadius: BorderRadius.circular(10),
      child: Text(text),
      onPressed: onPressed,
    );
  }
}
