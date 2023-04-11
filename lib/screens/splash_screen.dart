import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_bay/screens/home_screen.dart';

import '../api/apis.dart';
import 'authetication/login_screen.dart';


class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), (){

      // Exit Full Screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // Transparent AppBar
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, statusBarColor: Colors.blue));

      if(APIs.auth.currentUser != null){
        // Print User details
        log('\nUser : ${APIs.auth.currentUser}');

        // Navigate to HomeScreen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      }else{
        // Navigate to LoginScreen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blueAccent, Colors.lightBlueAccent, Colors.lightBlueAccent],
          ),
        ),
        child: Center(child: Image.asset('images/appLogo.png')),

      ),

    );
  }
}