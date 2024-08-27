
import 'dart:convert';

import 'package:chat_app/data/datasources/chat_api.dart';
import 'package:http/http.dart';

class IhChatApi extends ChatApi{
  //var client = HttpClient();
  final apiServer = "127.0.0.1";//:8080";
  int apiPort = 8080;
  void init() {}

  @override
  Future<dynamic> register(String username, String email, String pwd) async {
    //client.pos
    //var resp = await client.post(apiServer, apiPort, "/register");
    final body = {
      "username": username,
      "email": email,
      "pwd": pwd
    };
    final headers = {
      "Content-Type": "application/json"
    };

    var resp = await post(Uri(scheme: "http", host: apiServer, port: apiPort, path: "/register"), headers: headers, body: body);

    return jsonDecode(resp.body);    
  }
}