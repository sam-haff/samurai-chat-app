import 'package:equatable/equatable.dart';

enum ResponseCode{
  Success,
  UserAlreadyRegistered,
  UsernameTaken,
  UsernameTooShort, 
  ReceiverDoesNotExist,
  EmailProfileAuthInvariantBroken,
  CantCreateAuthUser,
  CodeUserNotRegistered,
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
  });


  final ResponseCode code;
  final String msg;
  final String? uid;
  final String? token;
  final String? url;


  @override
  List<Object?> get props => [code, msg, uid, token, url];
}

ResponseCode _codeToRespCode(int code) {
  return ResponseCode.values[code];
}

ResponseStatus ParseServerCallResponse(dynamic data) {
  try {
    return ResponseStatus(code: _codeToRespCode(data['result']['code']), msg: data['result']['msg']);
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