import 'dart:ffi';

import 'package:equatable/equatable.dart';

enum ResponseCode{
  Success, //0
  UserAlreadyRegistered, //1
  UsernameTaken, //2
  UsernameTooShort, //3
  ReceiverDoesNotExist, //4
  EmailProfileAuthInvariantBroken, //5
  CantCreateAuthUser, //6
  CodeUserNotRegistered, //7
  CodeNotAuthenticated,
  CodeMaximumTokensNumberReached,
  CodeDeviceNameTooLong,
  //local codes
  Exception,
}

class ResponseStatus extends Equatable{
  ResponseStatus({
    required this.code,
    required this.msg,
    this.uid,
    this.token,
    this.url,
    this.obj,
  });

  static String safeCastStr(dynamic obj) {
    return obj != null ? obj as String : "";
  }

  factory ResponseStatus.fromMap(dynamic json) {
    var code = json["code"];
    var msg = json["msg"];
    var uid = json["uid"];
    var token = json["token"];
    var url = json["url"];  // really need it that way, sometimes we needed/may need several of them set at a time

    ResponseCode? parsedCode;
    if (code != null) {
      var codeInt = code as int;
      parsedCode = ResponseCode.values[codeInt]; // TODO: CHECK IS NEEDED HERE
    }
    
    return ResponseStatus(code: _codeToRespCode(json['code']), msg: safeCastStr(msg), uid: safeCastStr(uid), token: safeCastStr(token), url: safeCastStr(url), obj: json["obj"]);

  }

  ResponseCode code;
  String msg;
  String? uid;
  String? token;
  String? url;
  dynamic obj;


  @override
  List<Object?> get props => [code, msg, uid, token, url];
}

ResponseCode _codeToRespCode(int code) {
  return ResponseCode.values[code];
}

ResponseStatus ParseServerCallResponse(dynamic data) {
  try {
    print("start there");
    print(data['result']);
    return ResponseStatus.fromMap(data['result']);//Map<String, dynamic>.from(data['result'] as Map));
    //mb do some logging here to make sure it's working alright

    //return ResponseStatus(code: _codeToRespCode(data['result']['code']), msg: data['result']['msg']);
  } on Exception {
    return ResponseStatus(code: ResponseCode.Exception, msg: 'Bad response'); 
  }
}

ResponseStatus ParseServerCallResponseWithUid(dynamic data) {
  try {
    final res = data['result'];
    return ResponseStatus(code: _codeToRespCode(res['code']), msg: res['msg'], uid: res['user_id']);
  } on Exception {
    return ResponseStatus(code: ResponseCode.Exception, msg: 'Bad response'); 
  }
}

ResponseStatus ParseServerCallResponseWithToken(dynamic data) {
  try {
    final res = data['result'];
    return ResponseStatus(code: _codeToRespCode(res['code']), msg: res['msg'], token: res['token']);
  } on Exception {
    return ResponseStatus(code: ResponseCode.Exception, msg: 'Bad response'); 
  }
}