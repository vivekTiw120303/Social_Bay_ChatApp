import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../models/chat_user.dart';
import 'authetication/login_screen.dart';

class ProfileScreen extends StatefulWidget{
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final _formKey = GlobalKey<FormState>();

  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      // Hiding the keyboard on tapping screen
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
            ),
          ),
        ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent.shade200,
              onPressed: () async{
                // Show Progress Bar
                Dialogs.showProgressBar(context);

                // If the user logout then update to OFFLINE status
                await APIs.updateActiveStatus(false);

                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {

                    // Hide Progress Bar
                    Navigator.pop(context);
                    // Empty HomeScreen from Stack
                    Navigator.pop(context);

                    APIs.auth = FirebaseAuth.instance;

                    // Navigate to Login Screen
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                  });
                });

              },
              icon: Icon(Icons.logout_outlined),
              label: Text('Sign Out'),
          ),
        ),

        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  // Space
                  SizedBox(height: 30,),

                  // Profile Pic with Edit Button
                  Stack(
                    children: [

                      // User Profile Pic
                      _image != null
                        ?

                  // Local Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(110),
                    child: Image.file(
                      File(_image!),
                      fit: BoxFit.cover,
                      height: 200,
                      width: 200,
                      ),
                  )

                      :

                  // Image from server
                  ClipRRect(
                    borderRadius: BorderRadius.circular(110),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      height: 200,
                      width: 200,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => CircleAvatar(child : Icon(Icons.person_2_rounded)),
                    ),
                  ),


                  // Edit Button for User Profile
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 3,
                          splashColor: Colors.grey,
                          onPressed: (){
                            _showBottomSheet();
                          },
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Icon(Icons.edit_rounded),
                        ),
                      )
                    ],
                  ),

                  // Space
                  SizedBox(height: 15,),

                  // User's Email
                  Text(widget.user.email, style: TextStyle(color: Colors.black54, fontSize: 15),),

                  // Space
                  SizedBox(height: 25,),

                  // User Name field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      onSaved: (val) => APIs.me.name = val ?? ' ',

                      validator: (val) => val != null && val.isNotEmpty ? null : 'Field is empty',

                      initialValue: widget.user.name,
                      keyboardType: TextInputType.name,
                      obscureText: false,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: 'Name',
                      ),
                    ),
                  ),

                  // Space
                  SizedBox(height: 12,),

                  // Info field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      onSaved: (val) => APIs.me.mood = val ?? ' ',

                      validator: (val) => val != null && val.isNotEmpty ? null : 'Field is empty',

                      initialValue: widget.user.mood,
                      keyboardType: TextInputType.name,
                      obscureText: false,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.info_outline_rounded),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: 'About',
                      ),
                    ),
                  ),

                  // Space
                  SizedBox(height: 18,),

                  // Update Button
                  Container(
                    width: 200,
                    height: 50,
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                        ),
                        onPressed: (){
                          if(_formKey.currentState!.validate()){
                            _formKey.currentState!.save();
                            APIs.updateUserInfo().then((value){
                              Dialogs.showSnackBar(context, 'Profile Update Successfully !');
                            });
                          }
                        },
                        icon: Icon(Icons.edit_rounded),
                        label: Text('UPDATE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(23), topRight: Radius.circular(23)),
        ),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 11.0,bottom: 11.0),
            children: [
                  Text("Pick your Profile Picture",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),),

                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      // Choose from Gallery
                      ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            // Pick an image.
                            final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                            if(image != null){
                              log('Image : ${image.path}');

                              setState(() {
                                _image = image.path;
                              });

                              APIs.updateProfilePicture(File(_image!));

                              // Then pop the dialog
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            backgroundColor: Colors.white,
                            shape: CircleBorder(),
                            visualDensity: VisualDensity(vertical: 2.0, horizontal: 2.0),
                            fixedSize: Size(120, 120),
                          ),
                          child: Image.asset('images/gallery.png'),
                      ),

                      // Choose from Camera
                      ElevatedButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                          if(image != null){
                            log('Image : ${image.path}');

                            setState(() {
                              _image = image.path;
                            });

                            APIs.updateProfilePicture(File(_image!));

                            // Then pop the dialog
                            Navigator.pop(context);
                          }

                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(120, 120),
                        ),
                        child: Image.asset('images/camera.png'),
                      ),
                    ],
                  ),
              SizedBox(height: 20,),
                ]
              );
        }
    );
  }
}