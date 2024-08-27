import 'package:chat_app/bloc/contacts/contacts_cubit.dart';
import 'package:chat_app/bloc/contacts/contacts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewContact extends StatefulWidget {
  @override
  State<NewContact> createState() => _NewContactState();
}

class _NewContactState extends State<NewContact> {
  final _textController = TextEditingController();
  final _statesController = WidgetStatesController();
  String? _errorMsg;
  void _addContact(BuildContext ctx) {
    ctx.read<ContactsCubit>().requestAddContact(_textController.text);

    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _errorMsg = context.watch<ContactsCubit>().state.failed ? 'Such user is not registered' : null;
    print(_errorMsg);
    return BlocListener<ContactsCubit, ContactsState>(
      listener: (context, state) {
        if (state.failed) {
          setState(() {
            _statesController.update(WidgetState.error, true);
          });
        } else {
          setState(() {
            _statesController.update(WidgetState.error, false);
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    statesController: _statesController,
                    decoration: InputDecoration(
                        labelText: 'Enter username...',
                        errorText: _errorMsg),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _addContact(context);
                  },
                  icon: Icon(Icons.arrow_right_alt),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
