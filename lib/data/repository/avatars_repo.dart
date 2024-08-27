import 'dart:io';

import 'package:chat_app/data/repository/server_codes.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

const DummyAvatarImgUrl = 'https://firebasestorage.googleapis.com/v0/b/chat-app-67931.appspot.com/o/dummy.jpg?alt=media&token=f7f42329-e308-4f6e-9de7-2d9df417f0d4';

class AvatarsRepo{
  Future<ResponseStatus> uploadAvatar({required File img}) async {
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
      return ResponseStatus(code: ResponseCode.Exception, msg: 'Couldnt upload a file');
    }

    final imgUrl = await storageRef.getDownloadURL();

    return ResponseStatus(code: ResponseCode.Success, msg: 'Img uploaded', url: imgUrl);

  }
  Future<ResponseStatus> updateAvatar({required File img}) async {
    final uploadResp = await uploadAvatar(img: img);
    if (uploadResp.code != ResponseCode.Success) {
      return uploadResp;
    } 

    try {
      final avaUpdateRes = await FirebaseFunctions.instance.httpsCallable('updateavatar').call({
        'img_url': uploadResp.url,
      });
      final resp = ParseServerCallResponse(avaUpdateRes.data);
  
      return resp;
    } on Exception {
      return ResponseStatus(code: ResponseCode.Exception, msg: 'Internal exception');
    }
  }
}