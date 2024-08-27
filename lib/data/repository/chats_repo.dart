import 'package:chat_app/data/repository/server_codes.dart';
import 'package:chat_app/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';


class NewMessages {
  List<ChatMessage>? initial;
  List<ChatMessage> messages;

  NewMessages({this.initial = null, required this.messages});
}

class ChatsRepo {
  ChatMessage parseChatMessage(dynamic data) {
    return ChatMessage(
      from: data['from'] as String,
      to: data['to'] as String,
      msg: data['msg'] as String,
      fromUsername: data['username'] as String,
      imgUrl: data['img_url'] as String,
      timestamp: data['created_at'] as int,
    );
  }
  Future<ResponseStatus> sendMessage(String to, String msg) async {
    final res = await FirebaseFunctions.instance.httpsCallable('addmessage').call({
      'to': to,
      'text': msg,
    });

    ResponseStatus? resp = ParseServerCallResponseWithUid(res.data);
    return resp;
  }
  static String createCompositeKey(String withId) {
    List<String> ids = [FirebaseAuth.instance.currentUser!.uid, withId];
    ids.sort();
    String compositeKey = ids[0] + ids[1];

    return compositeKey;
  }

  Future<List<ChatMessage>> loadChat(String compositeKey) async {
    final snapshot = await FirebaseFirestore.instance
              .collection('chats')
              .doc(compositeKey)
              .collection('msgs')
              .orderBy('created_at').get();

    List<ChatMessage> r = [];
    for (final rawMsg in snapshot.docs) {
      r.add(parseChatMessage(rawMsg.data()));
    }

    return r;
  }
  Future<List<ChatMessage>> loadChatPage(String compositeKey, {required int pageSize, int? beforeTimestamp, bool inverse = false}) async {
    
    print('load chat page before');
    print(beforeTimestamp);
    print(inverse);
    final snapshot = beforeTimestamp != null ?
     await FirebaseFirestore.instance
              .collection('chats')
              .doc(compositeKey)
              .collection('msgs')
              .where('created_at', isLessThan: beforeTimestamp)
              .orderBy('created_at', descending: inverse)
              .limit(pageSize)
              .get()
              :
      await FirebaseFirestore.instance
              .collection('chats')
              .doc(compositeKey)
              .collection('msgs')
              .orderBy('created_at', descending: inverse)
              .limit(pageSize)
              .get();

    List<ChatMessage> r = [];
    for (final rawMsg in snapshot.docs) {
      r.add(parseChatMessage(rawMsg.data()));
      print(r.last.msg);
    }

    return r;
  }
  Stream<NewMessages> chatOnlyNew(String compositeKey, {int? afterTimestamp}) async* {   
    bool initial = true;

    //consider start after
    final snapshots = afterTimestamp == null ? 
                FirebaseFirestore.instance
              .collection('chats')
              .doc(compositeKey)
              .collection('msgs')
              .orderBy('created_at')
              .snapshots() 
              :
                FirebaseFirestore.instance
              .collection('chats')
              .doc(compositeKey)
              .collection('msgs').where('created_at', isGreaterThan: afterTimestamp)
              .orderBy('created_at')
              .snapshots();

    await for (var snapshot in snapshots) {
      List<ChatMessage>? initMsgs;

      if (initial) {
        initMsgs = [];
        for (final rawMsg in snapshot.docs){
          initMsgs.add(parseChatMessage(rawMsg.data()));
        }
        initial = false;
      }

      List<ChatMessage> newMsgs = [];
      for (final change in snapshot.docChanges){
        if (change.type == DocumentChangeType.added) {
          newMsgs.add(parseChatMessage(change.doc.data()));
        }
      }

      yield NewMessages(messages: newMsgs, initial: initMsgs);
    }
  }
  Stream<List<ChatMessage>> chat(String withId) async* {
    String compositeKey = createCompositeKey(withId);

    await for (var snapshot in FirebaseFirestore.instance
              .collection('chats')
              .doc(compositeKey)
              .collection('msgs')
              .orderBy('created_at')
              .snapshots()) {
      List<ChatMessage> r = [];

      for (final rawMsg in snapshot.docs){
        r.add(parseChatMessage(rawMsg.data()));
      }

      yield r;
    }
  }
}