
import 'dart:convert';

import 'package:chat_app/data/datasources/chat_api.dart';
import 'package:chat_app/data/repository/server_codes.dart';
import 'package:http/http.dart';

class IhChatApi extends ChatApi{
  //var client = HttpClient();
  final apiServer = "10.0.2.2";//"127.0.0.1";//:8080";
  int apiPort = 8080;
  void init() {}

  Uri getApiUri(String path) {
    return Uri(scheme: "http", host: apiServer, port: apiPort, path: path);
  }

  Map<String, String> getApiAuthHeaders(String auth) {
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + auth,
    };

    return headers;
  }

  @override
  Future<dynamic> register(String username, String email, String pwd) async {
    final body = {
      "username": username,
      "email": email,
      "pwd": pwd
    };
    final headers = {
      "Content-Type": "application/json"
    };

    var resp = await post(getApiUri("/register"), headers: headers, body: jsonEncode(body));

    return jsonDecode(resp.body);    
  }

  @override
  Future<dynamic> registerToken(String deviceName, String token, {String? authToken}) async{
    if (authToken == null) {
      throw Exception("registerToken requires auth");
      return null;
    }
    
    final headers = getApiAuthHeaders(authToken);
   
    final body = {
      "device_name": deviceName,
      "token": token
    };

    var resp = await post(getApiUri("/registertoken"), body: jsonEncode(body), headers: headers);

    return jsonDecode(resp.body);
  }

  @override
  
  Future<dynamic> completeRegister(String username, {String? authToken}) async {
    if (authToken == null) {
      throw Exception("completeRegister requires auth");
      return null;
    }
    
    final headers = getApiAuthHeaders(authToken);
    
    final body = {
      "username": username,
    };

    var resp = await post(getApiUri("/completeregister"), body: jsonEncode(body), headers: headers);

    return jsonDecode(resp.body);
  }
   @override
  Future<bool> userExists(String uid, {String? authToken}) async {
    if (authToken == null) {
      throw Exception("userExists requires auth");
      return false;
    }

    // TODO
    // maybe we shouldn't do any response interpretation
    // this code doesn't belong there

    
    var apiResp = (await recvUser(uid, authToken: authToken)) as Map<String, Map<String, dynamic>>; 

    var apiRespParsed = ResponseStatus.fromMap(apiResp["result"]!); //makes an ill dependency on "repository" system, question is should Response structs reside there or do they actually belong to "datasources"

    return apiRespParsed.code != ResponseCode.Success;
  }

  @override
  Future<dynamic> recvUser(String uid, {String? authToken}) async {
    if (authToken == null) {
      throw Exception("recvUser requires auth");
      return null;
    }

    final headers = getApiAuthHeaders(authToken);

    var resp = await get(getApiUri("/users/id/" + uid), headers: headers);

    return jsonDecode(resp.body);
  }
  @override
  Future<dynamic> recvUid(String username, {String? authToken}) async {
    if (authToken == null) {
      throw Exception("recvUid requires auth");
      return null;
    }

    final headers = getApiAuthHeaders(authToken);

    var resp = await get(getApiUri("/uid/" + username), headers: headers);

    return jsonDecode(resp.body);
  }
  @override
  Future<dynamic> updateAvatar(String imgUrl, {String? authToken}) async {
    if (authToken == null) {
      throw Exception("completeRegister requires auth");
      return null;
    }
    
    final headers = getApiAuthHeaders(authToken);
    
    final body = {
      "img_url": imgUrl,
    };

    var resp = await post(getApiUri("/updateavatar"), body: jsonEncode(body), headers: headers);

    return jsonDecode(resp.body);
  }

  @override
  Future<dynamic> sendMessage(String toUID, String text, {String? authToken}) async {
    if (authToken == null) {
      throw Exception("sendMessage requires auth");
      return null;
    }
    
    final headers = getApiAuthHeaders(authToken);
   
    final body = {
      "to": toUID,
      "text": text,
    };

    var resp = await post(getApiUri("/addmessage"), body: jsonEncode(body), headers: headers);

    return jsonDecode(resp.body);

  }

  @override

  Future<dynamic> getChatHistory(String withUid, {int? before, int? limit, bool inverse=false, String? authToken}) async {
    if (authToken == null) {
      throw Exception("getChatHistory requires auth");
      return null;
    }
    
    final headers = getApiAuthHeaders(authToken);
    const int intMaxValue = 9007199254740991; // TODO: check if mongo can work in64
    final body = {
      "with": withUid,
      "before_timestamp": before ?? intMaxValue,
      "limit": limit ?? 10000, // TODO: change default,
      "inverse": false,
    };

    var resp = await post(getApiUri("/chat"), body: jsonEncode(body), headers: headers);

    print("why");
    print("Chat resp " + resp.statusCode.toString());

    return jsonDecode(resp.body);

  }
}