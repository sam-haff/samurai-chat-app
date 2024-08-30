abstract class ChatApi {
  Future<dynamic> register(String username, String email, String pwd);
  Future<dynamic> registerToken(String deviceName, String token, {String? authToken});
  Future<dynamic> completeRegister(String username, {String? authToken});
  Future<bool> userExists(String uid, {String? authToken});
  Future<dynamic> recvUser(String uid, {String? authToken});
  Future<dynamic> recvUid(String username, {String? authToken});
  Future<dynamic> updateAvatar(String imgUrl, {String? authToken});

}