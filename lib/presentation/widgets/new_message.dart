import 'package:chat_app/data/repository/chats_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewMessage extends StatefulWidget {
  final String toUid;
  NewMessage({required this.toUid, super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _netSendMsg() async {
    final msg = _msgController.text;

    if (msg.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();

    await context.read<ChatsRepo>().sendMessage(widget.toUid, msg);

    _msgController.clear();
  }

  //TODO refactor to form
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              enableSuggestions: true,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Send a message...'
              ),
            ),
          ),
          IconButton(
            onPressed: _netSendMsg,
            icon: Icon(Icons.send), 
          )
        ],
      )
    );
  }
}