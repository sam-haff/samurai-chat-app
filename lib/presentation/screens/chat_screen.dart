import 'package:chat_app/bloc/auth/auth_cubit.dart';
import 'package:chat_app/bloc/auth/auth_state.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/presentation/widgets/chat_messages.dart';
import 'package:chat_app/presentation/widgets/fade_in_circular_avatar.dart';
import 'package:chat_app/presentation/widgets/new_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser withContact;
  const ChatScreen(
      {required this.withContact, super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.None) {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }  
      },
      child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            forceMaterialTransparency: false,
            shadowColor: Colors.white,
            elevation: 1,
            titleSpacing: 0,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              FadeInCircularAvatar(url: widget.withContact.imgUrl),
              Text(
                '   ${widget.withContact.username}',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
              )
            ]),
            actions: [
              
            ],
          ),
          body: Column(
            children: [
              Expanded(child: ChatMessages(withContact: widget.withContact,)),
              NewMessage(
                toUid: widget.withContact.uid,
              ),
            ],
          )),
    );
  }
}
