


import 'package:chat_app/data/datasources/chat_api.dart';
import 'package:chat_app/data/datasources/firebase/fb_chat_api.dart';
import 'package:chat_app/data/datasources/inhouse/ih_chat_api.dart';
import 'package:chat_app/data/repository/server_codes.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepo {
  bool useFirebase = true;

  ChatApi chatApi = IhChatApi();//FbChatApi();

  ChatUser? currentUser;
  Stream<ChatUser?> authStateChanges() async*{
    await for (var u in FirebaseAuth.instance.authStateChanges()) {
      print("Shell change :(");
      if (u != null) {
        print("Auth state change");
        var user = await recvUserByUid(u.uid);
        if (user == null) {
          print("Auth user id: " + u.uid);
          user = ChatUser(uid: u.uid, username: '', email: '', imgUrl: '');
        }
        currentUser = user;

        yield currentUser;
      } else {
        currentUser = null;
        yield null;
      }
    }
  }
  Future<ResponseStatus> register({required String email, required String username, required String pwd}) async {
    dynamic resData = await chatApi.register(username, email, pwd);

    ResponseStatus? resp = ParseServerCallResponse(resData);
    return resp;
  }
  Future<ResponseStatus> completeRegister({required String username}) async {
    print('Register username');
    print(username);
    final data = await chatApi.completeRegister(username, authToken: await FirebaseAuth.instance.currentUser!.getIdToken());

    ResponseStatus? resp = ParseServerCallResponse(data);
    return resp;
  }

  bool isAuthenticatedWithGoogle() {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null){
      return false;
    }
    if (auth.currentUser!.providerData.isEmpty) {
      return false;
    }

    return auth.currentUser!.providerData[0].providerId.compareTo(GoogleAuthProvider.PROVIDER_ID) == 0;
  }

  Future<ResponseStatus> registerToken({required String deviceName, required String token}) async {
    final data = await chatApi.registerToken(deviceName, token, authToken: await FirebaseAuth.instance.currentUser!.getIdToken());

    ResponseStatus? resp = ParseServerCallResponse(data);
    return resp;
  }
  Future<bool> isUserRegisterComplete(String uid) async {
    //final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    return chatApi.userExists(uid, authToken: await FirebaseAuth.instance.currentUser!.getIdToken());
  }
  Future<ResponseStatus> signOutFromGoogle() async {
    try {
      await GoogleSignIn().signOut();

      return ResponseStatus(code: ResponseCode.Success, msg: 'Signed out from Google');
    } on Exception catch (e) {
      return ResponseStatus(code: ResponseCode.Exception, msg: 'Couldnt singout from Google');
    }
  }
  Future<ResponseStatus> signInWithGoogle() async {
    GoogleSignInAccount? googleUser;

    GoogleSignInAuthentication? googleAuth;
 
    try {
      googleUser = await GoogleSignIn().signIn();
      googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      
      final userCreds = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCreds.user == null) {
        return ResponseStatus(code: ResponseCode.CodeNotAuthenticated, msg: 'Unexpected error, firebase didnt return user credential');
      }

      return ResponseStatus(code: ResponseCode.Success, msg: 'Singed in', uid: userCreds.user!.uid);
    } on FirebaseAuthException catch (e) {
      return ResponseStatus(code: ResponseCode.CodeNotAuthenticated, msg: 'Cant auth using provider, msg: ${e.message}');
    }
  }
  Future<ResponseStatus> signIn({required String email, required String pwd}) async {
    try {
      print("trying sign in");
      final userCreds = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: pwd);

      print("Got auth token for test!\n");
      print(await userCreds.user!.getIdToken());

      return ResponseStatus(code: ResponseCode.Success, msg: '', uid: userCreds.user!.uid);
    } on FirebaseAuthException catch (e){
      print(e.message) ;
      return ResponseStatus(code: ResponseCode.Exception, msg: e.message ?? '');
    }
  }
  Future<void> signOut() async {
    print("sing out with firebase");
    await FirebaseAuth.instance.signOut();
  }

  

  //returns null if username is not registered
  Future<String?> recvUidByUsername(String username) async {
    //final res = await FirebaseFirestore.instance.collection('usernames').doc(username).get();
    final res = await chatApi.recvUid(username, authToken:  await FirebaseAuth.instance.currentUser!.getIdToken());

    final resp = ParseServerCallResponse(res);

    if (resp.code == ResponseCode.Success) {
      return resp.obj['user_id'];
    }

    return null;
  }

  Future<ChatUser?> recvUserByUid(String uid) async {
    //final res = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final res = await chatApi.recvUser(uid, authToken: await FirebaseAuth.instance.currentUser!.getIdToken());

    var resp = ParseServerCallResponse(res);

    //if (res.exists && res.data() != null){
    if (resp.code == ResponseCode.Success) {
      print('Received user ' + resp.msg);
      final data = resp.obj;
      return ChatUser(username: data!['username'], uid: uid, email: data['email'], imgUrl: data['img_url']);
    } else {
      return null;
    }
  }

}