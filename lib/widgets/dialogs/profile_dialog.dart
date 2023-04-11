import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_bay/models/chat_user.dart';
import 'package:social_bay/screens/chat_screen.dart';
import 'package:social_bay/screens/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget{

  final ChatUser user;

  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),

      content: SizedBox(
        height: 300,
        width: 400,

        child: Stack(
          children: [

            // User Name
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                user.name, style: TextStyle(
                  color: Colors.black87,
                  fontSize: 21,
                  fontWeight: FontWeight.w500),
              ),
            ),

            // Icons
            Positioned(
              top: 250,
              left: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // Message to that person
                  MaterialButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: user)));
                    },
                    color: Colors.grey.shade300,
                    shape: StadiumBorder(),
                    splashColor: Colors.grey,
                    child: Icon(Icons.message_outlined),
                  ),

                  SizedBox(width: 11,),

                  // Profile Screen of that person
                  MaterialButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: user)));
                    },
                    color: Colors.grey.shade300,
                    shape: StadiumBorder(),
                    splashColor: Colors.grey,
                    child: Icon(Icons.info),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 45,
              left: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(110),
                child: CachedNetworkImage(
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover,
                  height: 180,
                  width: 180,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => CircleAvatar(child : Icon(Icons.person_2_rounded)),
                ),
              ),
            ),

          ],
        ),

      ),
    );
  }
}