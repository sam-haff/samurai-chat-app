// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class ChatUser extends Equatable {
  ChatUser({
    required this.username,
    required this.uid,
    required this.email,
    required this.imgUrl,
  });

  final String username;
  final String uid;
  final String email;
  final String imgUrl;

  

  @override
  List<Object> get props => [username, uid, email, imgUrl];


  ChatUser copyWith({
    String? username,
    String? uid,
    String? email,
    String? imgUrl,
  }) {
    return ChatUser(
      username: username ?? this.username,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'uid': uid,
      'email': email,
      'imgUrl': imgUrl,
    };
  }

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      username: map['username'] as String,
      uid: map['uid'] as String,
      email: map['email'] as String,
      imgUrl: map['imgUrl'] as String,
    );
  }
}
