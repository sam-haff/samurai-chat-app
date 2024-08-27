import 'package:chat_app/data/repository/chats_cache_repo.dart';

enum ChatStatus {
  loading,
  loadingHistory,
  loaded,
  newMessages,
}

class ChatState {
  bool lastPage;
  ChatMessagesList messages;
  ChatStatus status = ChatStatus.loading;
  String? chatID;

    ChatState({
    required this.messages,
    required this.status,
    this.chatID,
    required this.lastPage,
  });


  factory ChatState.initial() {
    return ChatState(messages: ChatMessagesList.empty(), status: ChatStatus.loading, lastPage: false);
  }

  ChatState copyWith({
    ChatMessagesList? messages,
    ChatStatus? status,
    String? chatID,
    bool? lastPage,    
  }) {
    return ChatState(
          messages: messages ?? this.messages,
      status: status ?? this.status,
      chatID: chatID != null ? chatID : this.chatID,
      lastPage: lastPage ?? this.lastPage,
    );
  }
}