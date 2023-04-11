import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';

import '../api/apis.dart';
import '../helper/dart_format_util.dart';
import '../helper/dialogs.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget{

  final Message message;

  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {

    bool isMe = APIs.user.uid == widget.message.fromId;

    // If sender is same then show same color msg else shift it
    return InkWell(

      onTap: (){
        if(widget.message.type == Type.image) _showImage();
      },

      onLongPress: (){
        _showBottomSheet(isMe);
      },

      child: isMe ? _greenMessage() : _orangeMessage(),
    );
  }

  // Sender Message
  Widget _orangeMessage(){

    // Update Read Status if both users are different
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // User Message Card
        Flexible(
          child: Container(

            padding: EdgeInsets.all(widget.message.type == Type.image ? 7 : 16),

            margin: EdgeInsets.symmetric(vertical: 11, horizontal: 7),

            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(30)
              ),
            ),

            // If type is Text then show text else image
            child: widget.message.type == Type.text
            ?  Text(
              widget.message.msg,
              style: TextStyle(fontSize: 15, color: Colors.black87),)
            : ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                placeholder: (context,url) => Center(child: SizedBox( height: 50 ,child: CircularProgressIndicator(strokeWidth: 2,))),
                imageUrl: widget.message.msg,
                errorWidget: (context, url, error) => Icon(Icons.image, size: 70,),
              ),
            ),
          ),
        ),

        // Sent Time
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 12),
    ),
        ),
      ],
    );
  }

  // User Message
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Row(
          children: [

            // Space
            SizedBox(width: 8,),

            // Read Icon
            if(widget.message.read.isNotEmpty)
              Icon(Icons.done_all_outlined,color: Colors.blue, size: 19,),


            // Space
            SizedBox(width: 4,),

            // Sent TIme
            Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 12),
            ),

          ],
        ),

        // User Message Card
        Flexible(
          child: Container(

            padding: EdgeInsets.all(widget.message.type == Type.image ? 7 : 16),

            margin: EdgeInsets.symmetric(vertical: 3, horizontal: 4),

            decoration: BoxDecoration(
              color: Colors.greenAccent.shade100,
              border: Border.all(color: Colors.green.shade700),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  topLeft: Radius.circular(30)
              ),
            ),

            // If type is Text then show text else image
            child: widget.message.type == Type.text
                ?  Text(
              widget.message.msg,
              style: TextStyle(fontSize: 15, color: Colors.black87),)
                : SizedBox(
                  height: 400,
                  width: 215,
                  child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  height: 500,
                  width: 250,
                  placeholder: (context,url) => Center(child: SizedBox( height: 50 ,child: CircularProgressIndicator(strokeWidth: 2,))),
                  imageUrl: widget.message.msg,
                  errorWidget: (context, url, error) => Icon(Icons.image, size: 70,),
              ),
            ),
                ),
          ),
        )

      ],
    );
  } // greenMessage

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(23), topRight: Radius.circular(23)),
        ),
        builder: (_) {
          return ListView(
              shrinkWrap: true,
              children: [

                Container(
                  height: 5,
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 120),

                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Copy Text Or Save Image Option
                widget.message.type == Type.text
                ? _OptionItem(  // Copy Text
                    icon: Icon(Icons.copy_all_rounded, size: 26, color: Colors.blue,),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value){

                        // Hide the bottom sheet
                        Navigator.pop(context);

                        // Show the dialog
                        Dialogs.showSnackBar(context, 'Text Copied to Clipboard');

                      });
                    }
                )

              : _OptionItem( // Save Image
                    icon: Icon(Icons.download_outlined, size: 26, color: Colors.blue,),
                    name: 'Download Image',
                    onTap: () async {
                      try{
                        await GallerySaver.saveImage(widget.message.msg, albumName: 'Social Bay').then((success){
                          // Hide the bottom sheet
                          Navigator.pop(context);

                          // Print the confirming Dialog
                          if(success!=null && success){
                            Dialogs.showSnackBar(context, 'Image Saved to Galley');
                          }
                        });
                        }catch(e){
                        log('\nSaveImageError : $e');
                      }
                    }
                ),

                // Share Message / Image
                _OptionItem(
                    icon: Icon(Icons.copy_all_rounded, size: 26, color: Colors.blue,),
                    name: 'Share Message',
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value){

                        // Share the message
                        Share.share(widget.message.msg);

                        // Show the dialog
                        Dialogs.showSnackBar(context, 'Text Copied to Clipboard');

                      });
                    }
                ),

                // Divider
                Divider(
                  color: Colors.black54,
                  endIndent: 30,
                  indent: 30,
                ),

                // Edit Text Option
                if(widget.message.type == Type.text && isMe)
                    _OptionItem(
                    icon: Icon(Icons.edit_outlined, size: 26, color: Colors.blue,),
                    name: 'Edit Text',
                    onTap: (){
                      _showUpdatedMessageDialog();
                    }
                ),

                // Delete Text Option
                if(isMe)
                  _OptionItem(
                      icon: Icon(Icons.delete_rounded, size: 26, color: Colors.red,),
                      name: 'Delete Message',
                      onTap: (){
                        APIs.deleteMessage(widget.message).then((value){
                          // Hide the bottom sheet
                          Navigator.pop(context);
                        });
                      }
                  ),

                // Divider
                if(isMe)
                  Divider(
                    color: Colors.black54,
                    endIndent: 30,
                    indent: 30,
                  ),

                // Sent At Option
                _OptionItem(
                    icon: Icon(Icons.remove_red_eye, color: Colors.blue,),
                    name: 'Sent At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                    onTap: (){}
                ),

                // Seen At Option
                _OptionItem(
                    icon: Icon(Icons.remove_red_eye, color: Colors.green,),
                    name: widget.message.read.isEmpty
                    ? 'Seen At : Not Seen Yet'
                    : 'Seen At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                    onTap: (){}
                ),

              ]
          );
        }
    );
  } // _showBottomSheet

  void _showUpdatedMessageDialog(){
    String updatedMsg = widget.message.msg;

    showDialog(context: context, builder: (_) => AlertDialog(
      elevation: 3,
      insetPadding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),

      // title
      title: Row(
        children: [
          Icon(Icons.message_outlined, size: 28, color: Colors.blue,),

          Text('Update Message'),
        ],
      ),

      // content
      content: TextFormField(
        initialValue: updatedMsg,
        maxLines: null,
        onChanged: (value) => updatedMsg = value,
        decoration: InputDecoration(
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
            APIs.updateMessage(widget.message, updatedMsg);
          },
          child: Text('Update', style: TextStyle(color: Colors.blue, fontSize: 17),),
        )
      ],

    ));
  }

  // Show image Zoom In version
  void _showImage(){
    showDialog(context: context, builder: (_) => AlertDialog(
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      shadowColor: Colors.grey,

      content: SizedBox(
        height: 600,
        width: 300,
        child: Stack(
          children: [

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                height: 595,
                width: 395,
                placeholder: (context,url) => Center(child: SizedBox( height: 50 ,child: CircularProgressIndicator(strokeWidth: 2,))),
                imageUrl: widget.message.msg,
                errorWidget: (context, url, error) => Icon(Icons.image, size: 70,),
              ),
            ),

          ],
        ),
      ),
    ));
  }

}

class _OptionItem extends StatelessWidget{
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),

      child: Padding(
        padding: const EdgeInsets.only(left: 11, top: 11, bottom: 14),
        child: Row(
          children: [
            icon,

            Flexible(child: Text('     $name',
              style: TextStyle(color: Colors.black87, fontSize: 16, letterSpacing: 0.5),)),
          ],
        ),
      ),
    );
  }
}