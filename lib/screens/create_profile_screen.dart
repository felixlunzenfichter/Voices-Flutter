import 'package:flutter/cupertino.dart';
import 'package:voices/constants.dart';
import 'package:voices/models/user.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/services/storage_service.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'navigation_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  final User user;

  CreateProfileScreen({@required this.user});

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  String _username;
  File _profilePic;

  bool _showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      progressIndicator: CupertinoActivityIndicator(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Profile'),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _changeProfilePic,
                child: Center(
                  heightFactor: 1.2,
                  child: _profilePic == null
                      ? Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            Opacity(
                              opacity: 0.4,
                              child: CachedNetworkImage(
                                imageUrl: kDefaultProfilePicUrl,
                                imageBuilder: (context, imageProvider) {
                                  return CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: imageProvider);
                                },
                                placeholder: (context, url) => SizedBox(
                                  height: 120,
                                  child: CupertinoActivityIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                            Icon(
                              CupertinoIcons.photo_camera_solid,
                              size: 50,
                            )
                          ],
                        )
                      : Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            Opacity(
                              opacity: 0.4,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: FileImage(_profilePic),
                                radius: 60,
                              ),
                            ),
                            Icon(
                              CupertinoIcons.photo_camera_solid,
                              size: 50,
                            )
                          ],
                        ),
                ),
              ),
              CupertinoTextField(
                placeholder: 'Enter your unique username',
                onChanged: (newUsername) {
                  _username = newUsername;
                },
              ),
              CupertinoButton(
                child: Text('Save'),
                onPressed: _uploadUser,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _changeProfilePic() async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('Take Photo'),
              onPressed: () {
                Navigator.pop(context);
                _setImage(ImageSource.camera);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Choose Photo'),
              onPressed: () {
                Navigator.pop(context);
                _setImage(ImageSource.gallery);
              },
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          )),
    );
  }

  void _setImage(ImageSource source) async {
    var selectedImage = await ImagePicker.pickImage(source: source);
    File croppedImage;
    // This do-while loop allows the user to return back to the camera or the gallery if he presses the back button in the image_cropper
    do {
      if (selectedImage != null) {
        croppedImage = await ImageCropper.cropImage(
            sourcePath: selectedImage.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            cropStyle: CropStyle.circle,
            androidUiSettings: AndroidUiSettings(
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
            ));
      }
      if (croppedImage != null) break;
      selectedImage = await ImagePicker.pickImage(source: source);
    } while ((croppedImage == null && selectedImage != null));
    if (croppedImage != null) {
      setState(() {
        _profilePic = croppedImage;
      });
    }
  }

  _uploadUser() async {
    setState(() {
      _showSpinner = true;
    });
    final storageService = Provider.of<StorageService>(context, listen: false);
    String imageUrl = kDefaultProfilePicUrl;
    if (_profilePic != null) {
      imageUrl = await storageService.uploadProfilePic(
          fileName: _username, image: _profilePic);
    }
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    User newUser = User(
        uid: widget.user.uid,
        phoneNumber: widget.user.phoneNumber,
        username: _username,
        imageUrl: imageUrl);
    await cloudFirestoreService.uploadUser(user: newUser);
    setState(() {
      _showSpinner = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
          builder: (context) => NavigationScreen(
                loggedInUser: newUser,
              )),

      ///NavigationScreen takes argument for development purposes
      (Route<dynamic> route) => false,
    );
  }
}
