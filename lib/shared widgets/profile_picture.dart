import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({
    Key key,
    @required this.imageUrl,
    @required this.radius,
  }) : super(key: key);

  final String imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      loadingBuilder: (context, child, progress) {
        return progress == null ? child : CupertinoActivityIndicator();
      },
      width: 2 * radius,
      height: 2 * radius,
      fit: BoxFit.cover,
    );
  }
}
