import 'dart:async';

import 'package:chat_app/data/repository/auth_repo.dart';
import 'package:chat_app/data/repository/chats_cache_repo.dart';
import 'package:chat_app/data/repository/chats_repo.dart';
import 'package:chat_app/models/chat_message.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/bloc/chat/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatsCacheRepo chatsCacheRepo;
  ChatsRepo chatsRepo;
  AuthRepo authRepo;
  StreamSubscription? newMsgsSub;

  String connectedChatID = '';
  ChatCubit({required this.chatsCacheRepo, required this.chatsRepo, required this.authRepo}) : super(ChatState.initial()){
    authRepo.authStateChanges().listen((ChatUser? user){
      if (user == null) {
        emit(state.copyWith( messages: ChatMessagesList.empty(), status: ChatStatus.loading, chatID: '', lastPage: false));
      }
    });
  }

  void _listenToNewMsgs(String chatID, int? afterTimestamp) {
    if (newMsgsSub != null) {
      newMsgsSub!.cancel();
    }
    newMsgsSub = chatsRepo.chatOnlyNew(chatID, afterTimestamp: afterTimestamp).listen(
        (NewMessages m) {
          print("chat cubit new message");
          //new partition handling

          if (m.initial != null) {
            emit(state.copyWith(messages: state.messages.copyWith(newPartion: [...state.messages.newPartition, ...m.initial!]), status: ChatStatus.newMessages));

            for (final msg in m.initial!) {
              chatsCacheRepo.cacheChatNewMessage(chatID, msg);
            }
          } else {
            for (final msg in m.messages) {
              chatsCacheRepo.cacheChatNewMessage(chatID, msg);
            }

            emit(state.copyWith(messages: state.messages.copyWith(newPartion: [...state.messages.newPartition, ...m.messages]), status: ChatStatus.newMessages));
          }
        }
      );
  }
  void fetchHistory(String withUid) async {
    String chatID = ChatsRepo.createCompositeKey(withUid);

    if (state.lastPage) {
      return;
    }
    if (state.status == ChatStatus.loadingHistory || state.status == ChatStatus.loading) {
      return;
    }

    emit(state.copyWith(status: ChatStatus.loadingHistory));
    
    int? earliestTimestamp = state.messages.initialPartition.isNotEmpty ? 
      state.messages.initialPartition.last.timestamp : DateTime.now().millisecondsSinceEpoch - 10; // minus one second so that it doesn't fetch new msgs that were sent nearly the same time
    if (state.messages.initialPartition.isEmpty && state.messages.newPartition.isNotEmpty) {
      earliestTimestamp = state.messages.newPartition.first.timestamp;
    }
    final msgs = await chatsRepo.loadChatPage(withUid, pageSize: 20, beforeTimestamp: earliestTimestamp, inverse: true);
    chatsCacheRepo.cacheHistoryPage(chatID, msgs);

    emit(state.copyWith(
      messages: state.messages.copyWith(initialPartition: [...state.messages.initialPartition, ...msgs]),
      lastPage: msgs.isEmpty,
      status: ChatStatus.loaded,
    )); 
  }
  Future<void> loadChat(String withUid) async {
    final chatID = ChatsRepo.createCompositeKey(withUid);

    emit(state.copyWith(chatID: chatID, messages: ChatMessagesList.empty(), status: ChatStatus.loading, lastPage: false));
    ChatMessagesList? msgs = chatsCacheRepo.loadChat(chatID);

    if (msgs != null) {
      emit(state.copyWith(messages: msgs, status: ChatStatus.loaded, chatID: chatID));

      print("loadChat len " + msgs.initialPartition.length.toString());
      print("loadChat len " + msgs.newPartition.length.toString());

      _listenToNewMsgs(chatID, msgs.lastTimestamp()!);
      return;
    }
    List<ChatMessage> history = await chatsRepo.loadChatPage(withUid, pageSize: 20, inverse: true);//await chatsRepo.loadChat(chatID);
    chatsCacheRepo.cacheChatInitial(chatID, history);
    emit(state.copyWith(messages: ChatMessagesList(initialPartition: history, newPartition: []), status: ChatStatus.loaded));

    int? timestamp = history.isEmpty ? null : history.first.timestamp;
    _listenToNewMsgs(chatID, timestamp);
  }

}