import 'dart:async';

import 'package:chat_app/data/repository/auth_repo.dart';
import 'package:chat_app/data/repository/chats_cache_repo.dart';
import 'package:chat_app/data/repository/notifications_repo.dart';
import 'package:chat_app/data/repository/server_codes.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/bloc/auth/auth_state.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_udid/flutter_udid.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  final ChatsCacheRepo chatsCacheRepo;
  final NotificationsRepo notificationsRepo;
  late StreamSubscription authStateChangeSub;
  void Function(ChatUser)? onSignIn;

  @override
  void onChange(Change<AuthState> change) {
    // TODO: implement onChange
    super.onChange(change);
    print("Curr state " + change.currentState.toString() + ", next: " + change.nextState.toString());
  }

  AuthCubit({required this.authRepo, required this.chatsCacheRepo, required this.notificationsRepo}): super(AuthState.initial()) {

    authStateChangeSub = authRepo.authStateChanges().listen( 
      (ChatUser? user) async {
        print("GOT CHANGE");
        if (user == null) {
          print("NULL CHANGE HAHA");
        }
        if (user != null) {
          final registerComplete = user.username.isNotEmpty; 
          print("!!!!!!!!!!! GOT CHANGE " + registerComplete.toString());
          if (registerComplete) {
            if (onSignIn != null) {
              onSignIn!(user);
            }

            _setSignedIn(user);
          } else {
            print("GOT NEEDS COMPLETE PROFILE");
            _setNeedsCompleteProfile(user);
          }
        } else if (state.user != null) {
          chatsCacheRepo.clear();
          _setSignedOut();
        }
      }
    );

  }

  void _setNeedsCompleteProfile(ChatUser user) {
    emit(state.copyWith(status: AuthStatus.NeedsCompleteProfile, user: user, errorStatus: null ));
  }

  bool _authOperationInProgress() {
    return (state.status == AuthStatus.SingingIn || state.status == AuthStatus.NeedsCompleteProfile || state.status == AuthStatus.SingingOn);
  }

  Future<bool> trySignInWithGoogle() async {
    if (_authOperationInProgress()) {
      return false;
    }

    emit(state.copyWith(status: AuthStatus.SingingIn, errorStatus: null));

    final resp = await authRepo.signInWithGoogle();

    if (resp.code != ResponseCode.Success) {
      emit(state.copyWith(status: AuthStatus.None, errorStatus: resp));
      return false;
    } else {
      if (state.user!.username.isNotEmpty){
        await registerNotificationsToken();
      }

      return true;
    }
  }
  Future<bool> tryCompleteRegisterAndSignIn(String username, {void Function(ChatUser)? newOnSignIn}) async {
    onSignIn = newOnSignIn;
    
    if (state.status != AuthStatus.NeedsCompleteProfile) {
      return false;
    }

    final resp = await authRepo.completeRegister(username: username);
    //print(resp.msg);
    final user = await authRepo.recvUserByUid(state.user!.uid);
    //print(user!.email);
    

    if (resp.code == ResponseCode.Success){
      if (onSignIn != null) {
        onSignIn!(user!);
      }

      registerNotificationsToken();
      // we update user here because prev user had only UID field populated(from state NeedCompleteProfile)
      emit(state.copyWith(status: AuthStatus.SignedIn, user: user));

      return true;
    } else {
      emit(state.copyWith(errorStatus: resp));
      
      return false;
    }
  }
  Future<ResponseStatus> registerNotificationsToken() async {
    final token = await notificationsRepo.setupPushNotifications();
    if (token != null) {
      final deviceId = await FlutterUdid.udid;
      return await authRepo.registerToken(deviceName: deviceId!, token: token!);
    } else {
      print('Got no token :(');
      return ResponseStatus(code: ResponseCode.Exception, msg: 'Got no token');
    }
  }
  Future<bool> trySignIn(String email, String pwd, {void Function(ChatUser)? newOnSignIn}) async {
    if (_authOperationInProgress()) {
      return false;
    }

    emit(state.copyWith(status: AuthStatus.SingingIn, errorStatus: null));
    onSignIn = newOnSignIn;    

    final resp = await authRepo.signIn(email: email, pwd: pwd);
    print(resp.msg);

    if (resp.code != ResponseCode.Success) {
      emit(state.copyWith(status: AuthStatus.None, errorStatus: resp));
      return false;
    } else {
      final notsResp = await registerNotificationsToken();

      return true;
    }
  }
  Future<bool> trySignUp({required String email, required String username, required String pwd}) async {
    if (_authOperationInProgress()){
      return false;
    }

    emit(state.copyWith(status: AuthStatus.SingingOn, errorStatus: null));
    print("Starting register procedure..........");
    final resp = await authRepo.register(email: email, username: username, pwd: pwd);
    print("Registered! WAHA!!!");
    if (resp.code != ResponseCode.Success) {
      print("OH:((((((((((  NO SUCCESS  ))))))))))");
      emit(state.copyWith(status: AuthStatus.None, errorStatus: resp));
      return false;
    } else {
      emit(state.copyWith(status: AuthStatus.None)); //don't block sign in operation
      return true;
    }
  }
  Future<void> signOut() async {

    emit(state.copyWith(status: AuthStatus.SigningOut, errorStatus: null));
    
    //TODO: is it to be hidden in auth repo sign out?
    if (authRepo.isAuthenticatedWithGoogle()) {
      await authRepo.signOutFromGoogle();
    }
    await authRepo.signOut();
    
  }
  void _setSignedIn(ChatUser user) {
    emit(state.copyWith(status: AuthStatus.SignedIn, user: user, errorStatus: null));
  }
  void _setSignedOut() {
    emit(state.copyWith(status: AuthStatus.None, user: null, errorStatus: null));
  }
}