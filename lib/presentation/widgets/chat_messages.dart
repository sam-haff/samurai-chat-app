import 'package:chat_app/bloc/chat/chat_cubit.dart';
import 'package:chat_app/data/repository/chats_repo.dart';
import 'package:chat_app/models/chat_message.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/presentation/widgets/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/bloc/chat/chat_state.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class ChatMessages extends StatefulWidget {
  final ChatUser withContact;
  const ChatMessages({required this.withContact,  super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChatMessagesState();
  }
  
}

class _ChatMessagesState extends State<ChatMessages> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    context.read<ChatCubit>().loadChat(ChatsRepo.createCompositeKey(widget.withContact.uid));

    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        } else {
        }
      }
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: _scrollController,
      thickness: 10,
      radius: Radius.circular(10),
      child: //StreamBuilder(
          //stream: context.read<ChatsRepo>().chat(widget.withContact.uid),
        BlocConsumer<ChatCubit, ChatState>(
          listener: (context, state) {
          },
          builder: (context, state) {
            print(state.messages.initialPartition.length);
            if (state.status == ChatStatus.loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state.messages.isEmpty()) {
              return Center(
                child: Text("No messages yet"),
              );
            }
            
            
            final msgs = state.messages;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: //ListView.builder(
              InfiniteList(
                reverse: true,
                debounceDuration: Duration(milliseconds: 20),
                hasReachedMax: state.lastPage,
                isLoading: state.status == ChatStatus.loadingHistory,
                onFetchData: () {
                  context.read<ChatCubit>().fetchHistory(ChatsRepo.createCompositeKey(widget.withContact.uid));
                },
                scrollController: _scrollController,
                  itemCount: msgs.length(),
                  itemBuilder: (ctx, idx) {
                    ChatMessage msg = msgs.reverseAt(idx);//msgs[idx];
                    ChatMessage? nextMsg = (idx < msgs.length() - 1) ? msgs.reverseAt(idx + 1) : null;//idx > 0 ? msgs[idx-1] : null;
                    
                    return Message(
                        username: msg.fromUsername,
                        isFirst: idx == (msgs.length() - 1) || (idx > 0 && nextMsg!.from.compareTo(msgs.reverseAt(idx).from) != 0),
                        isMy: msg.from.compareTo(FirebaseAuth.instance.currentUser!.uid) == 0 ,
                        userAvatarUrl: msg.imgUrl,
                        msg: msg.msg
                      );
                  }),
            );
          }),
    );
  }
}