import 'package:chat_app/models/chat_message.dart';

class ChatMessagesList{
  //initial is stored in reverse order to lighten the addition of new element(to avoid O(n) insertion)
  List<ChatMessage> initialPartition = [];
  List<ChatMessage> newPartition = [];

    ChatMessagesList({
    required this.initialPartition,
    required this.newPartition
  });
  int length() {
    return initialPartition.length + newPartition.length;
  }
  ChatMessage at(int i) {
    if (i < 0) {
      throw OutOfMemoryError();
    }

    //reversed because grows into past :)
    if (i < initialPartition.length) {
      return initialPartition[initialPartition.length - i - 1];
    }

    int newPartionIdx = i - initialPartition.length;
    if (newPartionIdx >= newPartition.length) {
      throw OutOfMemoryError();
    }
    return newPartition[newPartionIdx];
  }
  ChatMessage reverseAt(int i) {
    if (i < 0) {
      throw OutOfMemoryError();
    }
    if (i < newPartition.length) {
      return newPartition[newPartition.length - i - 1];
    }
    if (i >= newPartition.length + initialPartition.length) {
      throw OutOfMemoryError();
    }
    int initialPartitionIdx = i - newPartition.length;
    // initial partition is already reversed
    // initialPartitionIdx = initialPartition.length - initialPartitionIdx - 1;

    return initialPartition[initialPartitionIdx];
  }
  operator [] (int i) {
    return at(i);
  }
  bool isEmpty() {
    return initialPartition.isEmpty && newPartition.isEmpty;
  }

  factory ChatMessagesList.empty() {
    return ChatMessagesList(initialPartition: [], newPartition: []);
  }

  void setPreloaded(List<ChatMessage> initial) {
    initialPartition = initial;
  }

  int? lastTimestamp() {
    if (newPartition.isNotEmpty) {
      return newPartition.last.timestamp;
    }
    if (initialPartition.isNotEmpty) {
      return initialPartition.first.timestamp;
    }

    return null;
  }

  ChatMessagesList clone() {
    return ChatMessagesList(initialPartition: [...initialPartition], newPartition: [...newPartition]);
  }
  ChatMessagesList copyWith({
    List<ChatMessage>? initialPartition,
    List<ChatMessage>? newPartion    
  }) {
    return ChatMessagesList(
          initialPartition: initialPartition ?? this.initialPartition,
      newPartition: newPartion ?? this.newPartition
    );
  }
}

class ChatsCacheRepo {
  ChatsCacheRepo();
  

  void clear() {
    chats.clear();
  }

  Map<String, ChatMessagesList> chats = {};

  ChatMessagesList? loadChat(String chatID) {
    if (chats.containsKey(chatID)) {
      ChatMessagesList r = chats[chatID]!.clone();
      return r;
    }

    return null;
  }

  void cacheChatInitial(String chatID, List<ChatMessage> msgs){
    chats[chatID] = ChatMessagesList.empty();
    chats[chatID]!.initialPartition = [...msgs];
  }

  //overwrites new partition of the cached chat
  void cacheChatNew(String chatID, List<ChatMessage> msgs) {
    chats[chatID]!.newPartition = [...msgs];
  }

  //adds new message to new partitions of the cached chat
  void cacheChatNewMessage(String chatID, ChatMessage msg) {
    chats[chatID]!.newPartition.add(msg);
  }
  //msgs should be inversed in tstmp
  void cacheHistoryPage(String chatID, List<ChatMessage> msgs) {
    chats[chatID]!.initialPartition.addAll(msgs);
  }
}