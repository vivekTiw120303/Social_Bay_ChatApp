import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_bay/screens/profile_screen.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import '../widgets/sidebar.dart';

class HomeScreen extends StatefulWidget{
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // for storing users
  List<ChatUser>_list = [];

  // for storing searched users
  List<ChatUser>_searchList = [];

  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // TO real time Online and Offline status of the user
    SystemChannels.lifecycle.setMessageHandler((message) {

      if(APIs.auth.currentUser != null){

        // If user is on app => Online
        if(message.toString().contains('resume')) APIs.updateActiveStatus(true);

        // If app is in background or closed => Offline
        if(message.toString().contains('pause')) APIs.updateActiveStatus(false);

      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Hide the keyboard on tapping on screen
      onTap: () => FocusScope.of(context).unfocus(),

      child: WillPopScope(
        onWillPop: () {
          // If searching is On, then just close the search and return to home screen
          // Else exit the app
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },

        child: Scaffold(
          drawer: SideBar(),
          appBar: AppBar(
            centerTitle: true,

            title: _isSearching ? TextFormField(
              decoration: InputDecoration(
                hintText: 'Name, Email..',
                fillColor: Colors.white,
                filled: true,
              ),
              autofocus: true,
              style: TextStyle(fontSize: 16, letterSpacing: 0.5),

              // when search field is updated, then update the search list
              onChanged: (val) {
                // first clear the existing list
                _searchList.clear();

                // Now fill the search list with updated match
                for(var i in _list){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())){
                    _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                }
              },
            ) : Text('Social Bay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
              ),),

            actions: [

              SizedBox(
                width: 45,
                child: ElevatedButton(
                    onPressed: (){
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    child: Icon(_isSearching ? Icons.cancel_rounded : Icons.search)
                ),
              ),

              SizedBox(
                width: 45,
                child: ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)));
                    },
                    child: Icon(Icons.more_vert)
                ),
              )

            ],// actions
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () async {
                _showChtUserDialog();
            }, child: Icon(Icons.add_comment_sharp),
          ),

          body: StreamBuilder(
            stream: APIs.getMyUserID(),

            // Get the All IDS of the known users
            builder: (context, snapshot) {
              switch(snapshot.connectionState)
              {
                // If data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(child: CircularProgressIndicator());

                  // If data is empty or loaded
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return  StreamBuilder(
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? []
                    ),
                      builder: (context, snapshot) {
                        switch(snapshot.connectionState){
                          // If data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            // return Center(child: CircularProgressIndicator());

                            // If data is empty or loaded
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                              // If there are data available on firestore
                              if(_list.isNotEmpty){
                                return ListView.builder(
                                    itemCount: _isSearching ? _searchList.length : _list.length,
                                    padding: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (context,index){
                                      return ChatUserCard(user: _isSearching ? _searchList[index] : _list[index]);
                                    });
                              }else{  // If data is empty
                                return Center(child: Text('No Connections Found!', style: TextStyle(fontSize: 18),));
                              }
                        }
                        },
                    );
              }
              },
          ),
        ),
      ),
    );
  }

  // To add user dialog
  void _showChtUserDialog(){
    String email = "";

    showDialog(context: context, builder: (_) => AlertDialog(
      elevation: 3,
      insetPadding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),

      // title
      title: Row(
        children: [
          Icon(Icons.person_add, size: 28, color: Colors.blue,),

          Text(' Add User'),
        ],
      ),

      // content
      content: TextFormField(
        maxLines: null,
        onChanged: (value) => email = value,
        decoration: InputDecoration(
            hintText: 'Email Id',
            prefixIcon: Icon(Icons.email_sharp, color: Colors.blue,),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            )
        ),
      ),

      // Update + Cancel
      actions: [

        // Cancel Button
        MaterialButton(
          onPressed: (){
            // Hide the bottom sheet
            Navigator.pop(context);
          },
          child: Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 17),),
        ),

        // Update Button
        MaterialButton(
          onPressed: (){
            //Hide the bottom sheet
            Navigator.pop(context);

            // Updated the msg
            if(email.isNotEmpty){
              APIs.addUser(email).then((value){
                if(value){
                  Dialogs.showSnackBar(context, 'User Added Successfully');
                }else{
                  Dialogs.showSnackBar(context, 'User Not Found');
                }
              });
            }
          },
          child: Text('Add', style: TextStyle(color: Colors.blue, fontSize: 17),),
        )
      ],

    ));
  }
}