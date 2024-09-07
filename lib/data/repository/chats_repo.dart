import 'dart:async';

import 'package:chat_app/data/datasources/firebase/fb_chat_api.dart';
import 'package:chat_app/data/datasources/inhouse/ih_chat_api.dart';
import 'package:chat_app/data/repository/server_codes.dart';
import 'package:chat_app/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';


class NewMessages {
  List<ChatMessage>? initial;
  List<ChatMessage> messages;

  NewMessages({this.initial = null, required this.messages});
}

class NewMessagesStreamWithController {
  NewMessagesStreamWithController(this.controller, this.stream);

  StreamController<NewMessages> controller;
  Stream<NewMessages> stream;
}

ChatsRepo? chatsRepoPointer; // unfortunetely it's a requirement for a bg fcm handler to be a top context function(cant be inside a class)

// We do this for ih chat api because we can't have native listeners for new messages as when we were working with firebase
// One could consider using direct tcp connection/stream with mongo db watch on the server but that's unfeasible from the resources POV(client/server/mongo, all stages)
@pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    chatsRepoPointer!.ack = true;
    print("process msg");
    if (chatsRepoPointer == null) {
      return;
    }
    print(message.data);
    final isMsg = int.parse(message.data["is_msg"]);
    if (isMsg != 1){
      return;
    }

    ChatMessage msg = ChatMessage(from: message.data["_from"], to: message.data["to"], msg: message.data["msg"], fromUsername: message.data["username"], imgUrl: message.data["img_url"], timestamp: int.parse(message.data["created_at"]));
    final chatID = ChatsRepo.createCompositeKey2(msg.to, msg.from);
    print(chatsRepoPointer!.chatStreams.keys);
    print(chatID);
    if (chatsRepoPointer!.chatStreams.keys.contains(chatID)) {
      final stream = chatsRepoPointer!.chatStreams[chatID];
      NewMessages newMessages = NewMessages(messages: [msg]);
      stream!.controller.add(newMessages);
      print("put new msg to stream");
    }    
    print("New message arrived! From " + msg.from);
  }

class ChatsRepo {
  bool ack = false;
  var chatApi = IhChatApi();

  Map<String, NewMessagesStreamWithController> chatStreams = {};

  ChatsRepo() {
    if (chatApi is IhChatApi) {
      chatsRepoPointer = this;
      
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
    }
  }
  
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
    //final res = await FirebaseFunctions.instance.httpsCallable('addmessage').call({
    //  'to': to,
    //  'text': msg,
    //});
    print("Check ack " + ack.toString());
    final res = await chatApi.sendMessage(to, msg, authToken: await FirebaseAuth.instance.currentUser!.getIdToken());

    ResponseStatus? resp = ParseServerCallResponse(res);
    return resp;
  }
  static String createCompositeKey(String withId) {
    List<String> ids = [FirebaseAuth.instance.currentUser!.uid, withId];
    ids.sort();
    String compositeKey = ids[0] + ids[1];

    return compositeKey;
  }
  static String createCompositeKey2(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    String compositeKey = ids[0] + ids[1];

    return compositeKey;
  }

  Future<List<ChatMessage>> loadChat(String withUid) async {
    /*final snapshot = await FirebaseFirestore.instance
              .collection('chats')
              .doc(compositeKey)
              .collection('msgs')
              .orderBy('created_at').get();*/
    


    //List<ChatMessage> r = [];
    //for (final rawMsg in snapshot.docs) {
    //  r.add(parseChatMessage(rawMsg.data()));
    //}

    List<ChatMessage> r = [];

    if (chatApi is FbChatApi) {
      String compositeKey = createCompositeKey(withUid);
      var docs =  List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(await chatApi.getChatHistory(compositeKey, authToken: await FirebaseAuth.instance.currentUser!.getIdToken()));

      for (final rawMsg in docs) {
        r.add(parseChatMessage(rawMsg.data()));
        print(r.last.msg);
      }
    }
    if (chatApi is IhChatApi) {
      final res = chatApi.getChatHistory(withUid, authToken: await FirebaseAuth.instance.currentUser!.getIdToken());

      final resp = ParseServerCallResponse(res);

      if (resp.code != ResponseCode.Success) {
        return []; // should also handle not succesful case for FB version, since security rules can not allow the query
      } else {
        final msgs = List<Map<String, dynamic>>.from(resp.obj);
        print("Got messages count: " + msgs.length.toString());
        for (final rawMsg in msgs) {
          r.add(parseChatMessage(rawMsg));
        }
      }
    }

    return r;
  }
  Future<List<ChatMessage>> loadChatPage(String withUid, {required int pageSize, int? beforeTimestamp, bool inverse = false}) async {
    
    print('load chat page before');
    print(beforeTimestamp);
    print(inverse);
    /*final snapshot = beforeTimestamp != null ?
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
              .get();*/
    
    List<ChatMessage> r = [];

    if (chatApi is FbChatApi) {
      String compositeKey = createCompositeKey(withUid);
      var docs =  List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(await chatApi.getChatHistory(compositeKey, before: beforeTimestamp, limit: pageSize, inverse: inverse, authToken: await FirebaseAuth.instance.currentUser!.getIdToken()));

      for (final rawMsg in docs) {
        r.add(parseChatMessage(rawMsg.data()));
        print(r.last.msg);
      }
    }
    if (chatApi is IhChatApi) {
      final res = await chatApi.getChatHistory(withUid, before: beforeTimestamp, limit: pageSize, inverse: inverse, authToken: await FirebaseAuth.instance.currentUser!.getIdToken());

      final resp = ParseServerCallResponse(res);

      if (resp.code != ResponseCode.Success) {
        return []; // should also handle not succesful case for FB version, since security rules can not allow the query
      } else {
        if (resp.obj == null) {
          return [];
        }
        final msgs = List<Map<String, dynamic>>.from(resp.obj);
        if (msgs == null) {
          return [];
        }
        print("Chat history with " + withUid);
        print(resp.obj);
        print(msgs);
        print("Got messages count: " + msgs.length.toString());
        for (final rawMsg in msgs) {
          r.add(parseChatMessage(rawMsg));
        }
      }
    }

    return r;
  }
Stream<NewMessages> _fbChatOnlyNew(String compositeKey, {int? afterTimestamp}) async* {   
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
  Stream<NewMessages> chatOnlyNew(String compositeKey, {int? afterTimestamp}) {   
    if (chatApi is FbChatApi) {
      return _fbChatOnlyNew(compositeKey, afterTimestamp: afterTimestamp); 
    }

    Stream<NewMessages>? stream;
    if (chatStreams.keys.contains(compositeKey)) {
      stream = chatStreams[compositeKey]!.stream;
    } else {
      var controller = BehaviorSubject<NewMessages>(); // TODO: mb we can just always create new simple streams(with deleting the old ones obv) //StreamController<NewMessages>();
      stream = controller.stream;
      chatStreams[compositeKey] = NewMessagesStreamWithController(controller, stream); // TODO: save controller also to be able to close streams(for example if chat is deleted) 
    }
    return chatStreams[compositeKey]!.stream;
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