import 'package:chat_app/data/datasources/chat_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FbChatApi extends ChatApi {
  @override
  Future<dynamic> register(String username, String email, String pwd) async {
    final res = await FirebaseFunctions.instance.httpsCallable('register').call({
      'username': username,
      'email': email,
      'pwd': pwd,
    });

    return res.data;
  }
  @override
  Future<dynamic> registerToken(String deviceName, String token, {String? authToken}) async {
    final res = await FirebaseFunctions.instance.httpsCallable('registertoken').call({
      'device_name': deviceName,
      'token': token,
    });
    return res.data;
  }
  @override
  Future<dynamic> completeRegister(String username, {String? authToken}) async {
    final res = await FirebaseFunctions.instance.httpsCallable('completeregister').call({
      'username': username,
    });

    return res.data;
  }

  @override
  Future<bool> userExists(String uid, {String? authToken}) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    return userDoc.exists;
  }
  @override
  Future<dynamic> recvUser(String uid, {String? authToken}) async{
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return {'result' : {'code': 0, 'msg': 'Success', 'obj': userDoc.data()}};
    }
    return {"result": {'code': 7, 'msg': 'User not found'}};
  }

  @override
  Future<dynamic> recvUid(String username, {String? authToken}) async {
    final res = await FirebaseFirestore.instance.collection('usernames').doc(username).get();
    
    if (res.exists) {
      return {'result' : {'code': 0, 'msg': 'Success', 'obj': res.data()}};
    }
    return {"result": {'code': 7, 'msg': 'User not found'}};
  }
  @override
  Future<dynamic> updateAvatar(String imgUrl, {String? authToken}) async {
    print("api update ava");
    final avaUpdateRes = await FirebaseFunctions.instance.httpsCallable('updateavatar').call({
        'img_url': imgUrl,
      });
    
    print("api update ava status " + avaUpdateRes.data.toString());
    return avaUpdateRes.data;
  }

  @override
  Future<dynamic> sendMessage(String toUID, String text, {String? authToken}) async {
    final res = await FirebaseFunctions.instance.httpsCallable('addmessage').call({
      'to': toUID,
      'text': text,
    }); 

    return res.data;
  }

  @override

//not bothering with unification here, because it yields additional O(n) work, which is against my rules
//handle differencies with other apis in Repo code
  @override
  Future<dynamic> getChatHistory(String compositeKey, {int? before, int? limit, bool inverse=false, String? authToken}) async {
    var snapshotQ = before != null ?
      FirebaseFirestore.instance
              .collection('chats')
              .doc(compositeKey)
              .collection('msgs')
              .where('created_at', isLessThan: before)
              .orderBy('created_at', descending: inverse)
              :
      FirebaseFirestore.instance
              .collection('chats')
              .doc(compositeKey)
              .collection('msgs')
              .orderBy('created_at', descending: inverse);
    if (limit != null) {
      snapshotQ =  snapshotQ.limit(limit);
    }
    
    final snapshot = await snapshotQ.get();

    return snapshot.docs;
  }
}