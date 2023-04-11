import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helper/dart_format_util.dart';
import '../models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget{
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {

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

        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text('Joined on ', style: TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.bold),),

            Text(
              MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt, showYear: true),
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                // Space
                SizedBox(height: 30,),

                // Profile Pic
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

                // Space
                SizedBox(height: 18,),

                // User Name
                Center(child: Text(widget.user.name, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500, color: Colors.black),)),

                // Space
                SizedBox(height: 20),

                // User Details
                Row(
                  children: const [
                    Expanded(
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                    Text('  User Details  ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                    Expanded(
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),

                // Space
                SizedBox(height: 20,),

                // Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    SizedBox(width: 11,),

                    Text('Email : ', style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),),

                    SizedBox(width: 15,),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              color: Colors.yellowAccent.shade100,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                              child: Text(widget.user.email, style: TextStyle(fontSize: 17, color: Colors.blue),),
                            )
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(height: 15,),

                // Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    SizedBox(width: 11,),

                    Text('About : ', style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),),

                    SizedBox(width: 15,),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              color: Colors.yellowAccent.shade100,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                              child: Text(widget.user.mood, style: TextStyle(fontSize: 17, color: Colors.blue),),
                            )
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(height: 15,),

                // Online / Offline Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    SizedBox(width: 11,),

                    Text('Status : ', style: TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.bold),),

                    SizedBox(width: 15,),

                    widget.user.isOnline
                        ? Text('Online', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),)
                        : Text('Offline', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),)
                  ],
                ),
              ],
            ),

          ),
        ),
      ),
    );
  }
}