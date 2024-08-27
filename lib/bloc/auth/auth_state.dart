import 'package:chat_app/data/repository/server_codes.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus{
  None,
  SignedIn,
  NeedsCompleteProfile,
  SingingIn,
  SingingOn,
  SigningOut,
}

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.user,
    this.errorStatus
  });


  final ChatUser? user;
  final AuthStatus status;
  final ResponseStatus? errorStatus;

  factory AuthState.initial() {
    return AuthState(status: AuthStatus.None);
  } 
  AuthState copyWith({
    ChatUser? user,
    AuthStatus? status,
    ResponseStatus? errorStatus    
  }) {
    final nState = AuthState(
      user: user != null ? user : this.user,
      status: status ?? this.status,
      errorStatus: errorStatus,
    );

    print("New state " + nState.status.toString());

    return nState;
  }


  @override
  List<Object?> get props => [user, status, errorStatus];
}