import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget leading;
  final Widget middle;
  final Function onPress;
  final double paddingInsideHorizontal;
  final double paddingInsideVertical;

  CustomCard(
      {@required this.leading,
      @required this.middle,
      @required this.onPress,
      this.paddingInsideHorizontal = 15,
      this.paddingInsideVertical = 10});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: paddingInsideHorizontal,
              vertical: paddingInsideVertical),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.lightBlueAccent,
          ),
          child: Row(
            children: <Widget>[
              leading,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: middle,
                ),
              ),
              Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
