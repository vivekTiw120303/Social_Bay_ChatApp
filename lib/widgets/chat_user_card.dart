
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_bay/helper/dart_format_util.dart';
import 'package:social_bay/screens/chat_screen.dart';
import 'package:social_bay/widgets/dialogs/profile_dialog.dart';

import '../api/apis.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

class ChatUserCard extends StatefulWidget{

  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  // last message info
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(

      margin: EdgeInsets.symmetric(horizontal: 10 , vertical: 7),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user,)));
        },

        child: StreamBuilder(
          stream: APIs.getLastMessages(widget.user),
          builder: (context, snapshot){

            final data = snapshot.data!.docs;
            final list = data.map((e) => Message.fromJson(e.data())).toList();

            if(list.isNotEmpty) _message = list[0];

            return ListTile(

              // User Profile Picture
              leading: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user));
                },

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    width: 40,
                    height: 40,
                    errorWidget: (context,url,error) => CircleAvatar(
                      child: Icon(Icons.person_2_outlined),
                    ),

                  ),
                ),
              ),

              // User Name
              title: Text(
                widget.user.name,
                style: TextStyle(fontSize: 17),
              ),

              // Last Message
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                    ? 'image'
                    : _message!.msg : widget.user.mood,
                       maxLines: 1,
              ),

              trailing: _message == null
                  ? null // Show nothing
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid

                  ? Container( // show the unread message
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              )

                  : Text(
                MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                style: TextStyle(color: Colors.black54),
              ),
            );
          },)
      ),
    );
  }
}