import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String text;

  InfoDialog({@required this.title, @required this.text});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              CupertinoButton(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              )
            ],
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
    );
  }
}

showInfoDialog({@required BuildContext context, @required Widget dialog}) {
  showGeneralDialog(
      barrierColor: Colors.white.withOpacity(0.3),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return dialog;
      });
}
