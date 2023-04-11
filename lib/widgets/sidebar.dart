import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_bay/screens/profile_screen.dart';

import '../api/apis.dart';

class SideBar extends StatefulWidget{

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  @override
  Widget build(BuildContext context) {

    return Drawer(
      width: 250,

      child: ListView(
        children: [

          // Upper Decoration
          UserAccountsDrawerHeader(
            accountName: Text(APIs.me.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
            accountEmail: Text(APIs.me.email, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),),
            currentAccountPicture: CircleAvatar(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: APIs.me.image,
                  errorWidget: (context, url, error) => CircleAvatar(child : Icon(Icons.person_2_rounded)),
                ),
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/back.jpg',),
                fit: BoxFit.cover,
              )
            ),
          ),

          // Profile Screen
          ListTile(
            leading: Icon(Icons.person_2_outlined),
            title: Text('Profile'),
            onTap: () {

              // Hide it first
              Navigator.pop(context);

              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)));
            },
          ),

          // Exit
          ListTile(
            leading: Icon(Icons.exit_to_app_outlined),
            title: Text('Exit'),
            onTap: () {
              SystemNavigator.pop();
            },
          ),

        ],
      ),
    );
  }
}