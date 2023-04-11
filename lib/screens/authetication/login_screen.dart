import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_bay/screens/home_screen.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget{

  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();

    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isAnimate = true);
    });
  }

  _handleGoogleSignInClick(){

    // For showing Progress Bar
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async{

      // End the Progress Bar
      Navigator.pop(context);

      // TO print the information about the user
      if(user != null){
        log('User : ${user.user}');
        log('UserAdditionalCredentials : ${user.additionalUserInfo}');

        // Check if users exists then directly sow him else create one
        if((await APIs.userExists())){
          // TO navigate to HomeScreen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }else{
          APIs.createUser().then((value){
            // TO navigate to HomeScreen
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }


      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {

    try{

      // Trigger the authentication flow
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    }catch(e){
      log('\n_signInWithGoogle : $e');
      Dialogs.showSnackBar(context, 'Something Went Wrong !, Check your Internet Connection');
      return null;
    }
  }

  // Google Sign Out Function
  // _signOut() async{
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn.signOut();
  // }

  @override
  Widget build(BuildContext context) {

    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.cyanAccent.shade200,
        title: const Text('Social Bay', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w900),),
        centerTitle: true,
        elevation: 15,
      ),
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

              const SizedBox(height: 25,),

              // App logo
              AnimatedPositioned(
                  top: mq.height * .15,
                  right: _isAnimate ? mq.width * .25 : -mq.width * .5,
                  width: mq.width * .5,
                  duration: const Duration(seconds: 1),
                  child: Image.asset('images/appLogo.png')
              ),

              SizedBox(height: 10,),

            // Greetings
            Text('Hello, Welcome to Social Bay', style: TextStyle(
              color: Colors.blue.shade400,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
            ),

            SizedBox(height: 5,),

            // Greetings
            Text('Login and Deep Dive into the Bay', style: TextStyle(
              color: Colors.blue.shade400,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
            ),

              SizedBox(height: 20,),

              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueAccent.shade100),
                ),
                // On Pressed Sign In With Google
                  onPressed: (){
                    _handleGoogleSignInClick();
                  },

                  // Google Icon
                  icon: Image.asset('images/google.png', height: 25,),

                  label: RichText(
                    text: TextSpan(style: TextStyle(color: Colors.black, fontSize: 16,),
                      children: [
                        TextSpan(text: 'Login with '),
                        TextSpan(text: 'Google', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
              ),
          ],
      ),
      ),
    );
  }
}