import 'dart:io';

import 'package:chat_app/data/datasources/firebase/fb_chat_api.dart';
import 'package:chat_app/data/datasources/inhouse/ih_chat_api.dart';
import 'package:chat_app/data/repository/server_codes.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

const DummyAvatarImgUrl = 'https://firebasestorage.googleapis.com/v0/b/chat-app-67931.appspot.com/o/dummy.jpg?alt=media&token=f7f42329-e308-4f6e-9de7-2d9df417f0d4';

class AvatarsRepo{
  final chatApi = IhChatApi();//FbChatApi();
  Future<ResponseStatus> uploadAvatar({required File img}) async {
    print("upload avatar");
    final fbAuth = FirebaseAuth.instance;
    if (fbAuth.currentUser == null) {
      return ResponseStatus(code: ResponseCode.Exception, msg: 'No auth');
    }

    final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${fbAuth.currentUser!.uid}.jpg');
    final uploadRes = await storageRef.putFile(img);
    if (uploadRes.state == TaskState.error) {
      print("upload avatar failed");
      return ResponseStatus(code: ResponseCode.Exception, msg: 'Couldnt upload a file');
    }

    final imgUrl = await storageRef.getDownloadURL();
    print("Got img url " + imgUrl);

    return ResponseStatus(code: ResponseCode.Success, msg: 'Img uploaded', url: imgUrl);

  }
  Future<ResponseStatus> updateAvatar({required File img}) async {
    print("UPDATING AVA INTERNAL");

    final uploadResp = await uploadAvatar(img: img);
    if (uploadResp.code != ResponseCode.Success) {
      return uploadResp;
    } 

    try {
      print("AVATAR CHECK UP");
      //final avaUpdateRes = await FirebaseFunctions.instance.httpsCallable('updateavatar').call({
       // 'img_url': uploadResp.url,
      //});
      final res = await chatApi.updateAvatar(uploadResp.url!, authToken: await FirebaseAuth.instance.currentUser!.getIdToken());
      print("AVATAR CHECK UP 2");
      final resp = ParseServerCallResponse(res);

      print("UPDATE AVATAR PROBLEM");
      print(resp.code.name);
      print(resp.msg);

      return resp;
    } on Exception {
      return ResponseStatus(code: ResponseCode.Exception, msg: 'Internal exception');
    }
  }
}