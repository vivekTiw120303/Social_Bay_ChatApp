import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_bay/helper/dart_format_util.dart';
import 'package:social_bay/models/chat_user.dart';
import 'package:social_bay/screens/view_profile_screen.dart';
import 'package:social_bay/widgets/message_card.dart';

import '../api/apis.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget{
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  // List of Messages
  List<Message> _list = [];

  // handling text messages over controller
  final _textController  =  TextEditingController();

  // to know for showing emoji or not
  bool _showEmoji = false;

  // for checking if image(s) is uploading or not
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(

          onWillPop: () {
            // If searching is On, then just close the search and return to home screen
            // Else exit the app
            if(_showEmoji){
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            }else{
              return Future.value(true);
            }
          },

          child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                flexibleSpace: _appBar(),
              ),

              backgroundColor: Colors.blue.shade100,

              body: Column(
                children: [

                  Expanded(
                    child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {

                        switch(snapshot.connectionState){

                        // If data is loading
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());

                        // If data is empty or loaded
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];


                            // If there are data available on firestore
                            if(_list.isNotEmpty){
                              return ListView.builder(
                                  reverse: true,
                                  itemCount:  _list.length,
                                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context,index){
                                    return MessageCard(message: _list[index],);
                                  });
                            }else{ // If data is empty
                              return Center(child: Text('Say Hi! 👋', style: TextStyle(fontSize: 21),));
                            }
                        }
                      },
                    ),
                  ),

                  if(_isUploading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),

                  _chatInput(),

                  // For Showing Emojis
                  if(_showEmoji)
                    SizedBox(
                      height: 300,
                      child: EmojiPicker(
                        textEditingController: _textController,
                        config: Config(
                          columns: 7,
                          emojiSizeMax: 32 * (Platform.isAndroid ? 1.30 : 1.0),
                        ),
                      ),
                    )

                ],
              ),
            ),
        ),
        ),
      );
  }

  // Custom App Bar
  Widget _appBar(){
    return InkWell(
      splashColor: Colors.lightBlueAccent,
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {

          final data = snapshot.data?.docs;
          final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [

              // Back Arrow
              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: Icon(Icons.arrow_back_ios_new)),

              // Profile Picture
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: CachedNetworkImage(
                  height: 45,
                  width: 45,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  errorWidget: (context, url, error) => CircleAvatar(child : Icon(Icons.person_2_rounded)),
                ),
              ),

              SizedBox(width: 10,),

              // User Name and Last Seen
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Name
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: Colors.white),
                  ),

                  SizedBox(height: 2,),

                  // User Last Seen
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                        : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
                  ),
                ],
              )

            ],
          );
        },
      )
    );
  }

  // Chat Input UI
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 9),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Row(
                children: [

                  // Emoji button
                  IconButton(
                      onPressed: (){
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(Icons.emoji_emotions_outlined),
                      color: Colors.orange,
                  ),

                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      autocorrect: true,
                      enableIMEPersonalizedLearning: true,
                      onTap: (){
                        if(_showEmoji) _showEmoji = !_showEmoji;
                      },
                      decoration: InputDecoration(
                        hintText: 'Type Something..',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black, )
                      ),
                    ),
                  ),

                  // Gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick multiple images
                        final List<XFile>? images = await picker.pickMultiImage(imageQuality: 80);

                        // Upload image 1 by 1
                        for(var i in images!){

                          // While image is uploading make it visible
                          setState(() {
                            _isUploading=true;
                          });

                          await APIs.sendChatImage(widget.user,File(i.path));

                          // Once done make it hide
                          setState(() {
                            _isUploading=false;
                          });
                        }
                      },
                      icon: Icon(Icons.image),
                      color: Colors.black,
                  ),

                  // Camera button
                  IconButton(
                      onPressed: () async{
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(source: ImageSource.camera);

                        // If image is not null send it
                        if(image != null){

                          // While Uploading, show progress Indicator
                          setState(() {
                            _isUploading=false;
                          });

                          await APIs.sendChatImage(widget.user,File(image.path));

                          // And then hide it
                          setState(() {
                            _isUploading=false;
                          });
                        }
                      },
                      icon: Icon(Icons.camera_alt_outlined),
                      color: Colors.black,
                  ),

                  SizedBox(width: 6,),

                ],
              ),
            ),
          ),

          // Send Button
          MaterialButton(
            onPressed: (){
              if(_textController.text.isNotEmpty){

                // If its 1st time or not
                if(_list.isEmpty){
                  APIs.sendFirstMessage(widget.user, _textController.text, Type.text);
                }else{
                  APIs.sendMessage(widget.user, _textController.text, Type.text);
                }
                _textController.text = ' ';
              }
            },
            minWidth: 0,
            shape: CircleBorder(),
            child: Icon(Icons.send_outlined),
            padding: EdgeInsets.all(9),
            color: Colors.green,
          ),

        ],
      ),
    );
  }

}