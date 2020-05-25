import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:voices/constants.dart';
import 'package:voices/models/user.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:voices/screens/tabs_screen.dart';
import 'package:voices/services/auth_service.dart';
import 'package:voices/services/cloud_firestore_service.dart';
import 'package:voices/services/storage_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:voices/shared_widgets/next_button.dart';
import 'package:voices/shared_widgets/profile_picture.dart';
import 'package:voices/services/contact_service.dart';

class CreateProfileScreen extends StatefulWidget {
  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  String _username;
  File _profilePic;

  bool _showSpinnerOverlay = false;
  bool _showJustSpinner = true;

  @override
  void initState() {
    super.initState();
    _setMyContact();
  }

  @override
  Widget build(BuildContext context) {
    if (_showJustSpinner) {
      return CupertinoActivityIndicator();
    }
    return ModalProgressHUD(
      inAsyncCall: _showSpinnerOverlay,
      progressIndicator: CupertinoActivityIndicator(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Create Profile'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: _changeProfilePic,
                      child: Center(
                        heightFactor: 1.2,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            Opacity(
                                opacity: 0.4,
                                child: (_profilePic == null)
                                    ? ProfilePicture(
                                        imageUrl: kDefaultProfilePicUrl,
                                        radius: 60)
                                    : CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        backgroundImage: FileImage(_profilePic),
                                        radius: 60,
                                      )),
                            Icon(
                              CupertinoIcons.photo_camera_solid,
                              size: 50,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      child: CupertinoTextField(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        placeholder: 'Enter your unique username',
                        onChanged: (newUsername) {
                          _username = newUsername;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              NextButton(
                text: "Save",
                onPressed: _uploadUser,
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _setMyContact() async {
    final contactService = Provider.of<ContactService>(context, listen: false);
    final authService = Provider.of<LoggedInUserService>(context, listen: false);
    Contact myContact = await contactService.getFirstContactWithQuery(
        query: authService.loggedInUser.phoneNumber);
    if (myContact != null) {
      _profilePic = File.fromRawPath(myContact.avatar);
      _username = myContact.displayName;
    }
    setState(() {
      _showJustSpinner = false;
    });
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
        ),
      ),
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
      _showSpinnerOverlay = true;
    });
    final storageService = Provider.of<StorageService>(context, listen: false);
    String imageUrl = kDefaultProfilePicUrl;
    if (_profilePic != null) {
      imageUrl = await storageService.uploadProfilePic(
          fileName: _username, image: _profilePic);
    }
    final cloudFirestoreService =
        Provider.of<CloudFirestoreService>(context, listen: false);
    final authService = Provider.of<LoggedInUserService>(context, listen: false);
    User newUser = User(
        uid: authService.loggedInUser.uid,
        phoneNumber: authService.loggedInUser.phoneNumber,
        username: _username,
        imageUrl: imageUrl);
    await cloudFirestoreService.uploadUser(user: newUser);
    setState(() {
      _showSpinnerOverlay = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
        builder: (context) => TabsScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
