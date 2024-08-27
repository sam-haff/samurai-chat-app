// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:chat_app/data/repository/auth_repo.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:chat_app/bloc/contacts/contacts_state.dart';

class ContactsCubit extends HydratedCubit<ContactsState> {
  ContactsCubit({required this.authRepo}) : super(ContactsState.initial()){
    hydrate();
  }
  final AuthRepo authRepo;

  Future<void> requestAddContact(String username) async {
    emit(state.copyWith(failed: false));
  
    final uid = await authRepo.recvUidByUsername(username);
    if (uid != null) {
      final newContact = await authRepo.recvUserByUid(uid);

      var newState =
          state.copyWith(contacts: {...state.contacts, uid: newContact!});
      emit(newState);
    } else {
      final newState = state.copyWith(contacts: {...state.contacts}, failed: true); 
      emit(newState);
    }
  }
  @override
  Map<String, dynamic>? toJson(ContactsState state) {
    try {
      final json = state.toMap();
    return json;
    } on Exception {
      return null;
    }
  }

  @override
  ContactsState? fromJson(Map<String, dynamic> json) {
    try {
    return ContactsState.fromMap(json);
    } on Exception catch (e) {
      print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
      print(e.toString());
      return null;
    }
  }
}
