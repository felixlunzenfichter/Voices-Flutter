import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey,
            backgroundImage: imageProvider);
      },
      placeholder: (context, url) => SizedBox(
        width: 2 * radius,
        height: 2 * radius,
        child: CupertinoActivityIndicator(),
      ),
      errorWidget: (context, url, error) => SizedBox(
        width: 2 * radius,
        height: 2 * radius,
        child: Icon(Icons.error),
      ),
    );
  }
}
