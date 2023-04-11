import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:social_bay/models/chat_user.dart';
import 'package:social_bay/models/message.dart';

class APIs{

  // For user authentication
  static FirebaseAuth auth  = FirebaseAuth.instance;

  // For cloud firestore database
  static FirebaseFirestore firestore  = FirebaseFirestore.instance;

  // For cloud firestore storage
  static FirebaseStorage storage  = FirebaseStorage.instance;

  // to return current user
  static User get user => auth.currentUser!;

  // For storing self information
  static late ChatUser me;

  // for accessing firebase messaging (push notifications)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async{
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) => {
      if(t != null){
        me.pushToken = t,
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // Send Push Notifications
  static Future<void> sendPushNotifications(ChatUser chatUser, String msg) async{

    try{
      final body = {
        "to" : chatUser.pushToken,
        "notification" : {
          "title" : chatUser.name,
          "body" : msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data" : "User ID : ${me.id}",
        },
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
            HttpHeaders.contentTypeHeader : 'application/json',
            HttpHeaders.authorizationHeader : 'key='
        },
        body: jsonEncode(body),
      );
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    }catch(e){
      log('\n SendNotifications : $e');
    }
  }

  // Check if user Exists or Not
  static Future<bool> userExists() async{
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // Check if user Exists or Not
  static Future<bool> addUser(String email) async{
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if(data.docs.isNotEmpty && data.docs.first.id != user.uid){

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    }else{
      return false;
    }
  }

  // Get Self Information
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if(user.exists){
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        // First make it true, then update
        APIs.updateActiveStatus(true);

      }else{
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // TO create a new User
  static Future<void> createUser() async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        mood: "Hey, Let's Chat",
        name: user.displayName.toString(),
        createdAt: time,
        lastActive: time,
        isOnline: false,
        id: user.uid,
        pushToken: '',
        email: user.email.toString()
    ); // ChatUser

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // Get all users except us
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {
    return firestore
        .collection('users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        .snapshots();
  }

  // Get specific known ids of users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserID() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // Get getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore
        .collection('users')
        .doc(user.uid)
        .update({'is_online' : isOnline,
                 'last_active' : DateTime.now().millisecondsSinceEpoch.toString(),
                  'push_token' : me.pushToken
        }
    );
  }

  // To Update User Info
  static Future<void> updateUserInfo() async{
    await firestore.collection('users').doc(user.uid).update({
      'name' : me.name,
      'mood' : me.mood,
    });
  }

  // Update Image and store in firestore
  static Future<void> updateProfilePicture(File file) async{
    final ext = file.path.split('.').last; // Gets the extension : png/jpg
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    // Upload image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    // Update Image
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image' : me.image,
    });
  }

  // Get conversation UID
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // TO get all messages from specific conversation from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // Send 1st message from searched user
  static Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async{

    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value){
          sendMessage(chatUser, msg, type);
    });
}

  // Send Message to the User
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    
    // Message Sending time
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // Message to be sent
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time
    );

    final ref = firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');

    await ref.doc(time).set(message.toJson()).then((value) {
      sendPushNotifications(chatUser, type == Type.text ? msg : 'image');
    });
  }

  // Update the Read Status of te messages
  static Future<void> updateMessageReadStatus(Message message) async{

    firestore.collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // Get the Last message of the user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(ChatUser user) {
    return firestore.collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {

    // Gets the extension : png/jpg
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    // Upload Image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));

    // Update Image
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
    }

  // Delete the selected message
  static Future<void> deleteMessage(Message message) async{

    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    // If message is image delete it from firebase
    if(message.type == Type.image)
      await storage.refFromURL(message.msg).delete();
  }

  // Delete the selected message
  static Future<void> updateMessage(Message message, String updatedMsg) async{

    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg' : updatedMsg});
  }

}