import 'package:chat_app/presentation/widgets/fade_in_circular_avatar.dart';
import 'package:flutter/material.dart';

class Message extends StatelessWidget{
  final bool isFirst;
  final bool isMy;
  final String userAvatarUrl;
  final String username;
  final String msg;

  const Message({required this.isFirst, required this.isMy, required this.userAvatarUrl, required this.msg, required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, isFirst ? 12 : 0, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (!isMy)
            Column(
              children: [
                if (isFirst)
                  FadeInCircularAvatar(url: userAvatarUrl),
                if (!isFirst)
                  SizedBox(width: 40,),
              ],
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: isMy ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (isFirst)
                  Container(
                    margin: EdgeInsets.only(top: 16, left: 8, right: 8),
                    child: Text(username, style: TextStyle(fontWeight: FontWeight.bold),)
                  ),
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(left: 8, top: isFirst ? 0 : 4),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 222, 222, 222),
                    borderRadius: BorderRadius.only(
                      topLeft: isMy || !isFirst ? Radius.circular(10) : Radius.zero,
                      topRight: isMy && isFirst ? Radius.zero : Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))
                    ),
                  child: Text(msg,),
                ),
            
              ],
            ),
          ),
          if (isMy)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isFirst)
                  FadeInCircularAvatar(url: userAvatarUrl),
                if (!isFirst)
                  SizedBox(width: 40,) 
              ],
            ),
            
        ],
      ),
    );
  }
}