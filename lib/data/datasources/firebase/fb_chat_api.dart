import 'package:chat_app/data/datasources/chat_api.dart';
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
}