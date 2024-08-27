import 'package:flutter/material.dart';

class AuthFormUsernameField extends StatelessWidget {
  final Function(String? val) onSaved;
  const AuthFormUsernameField({required this.onSaved, super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextFormField(
            decoration: InputDecoration(
              labelText: 'username',
            ),
            autocorrect: false,
            enableSuggestions: false,
            validator: (val) {
              if (val == null ||
                  val.trim().isEmpty ||
                  val.trim().contains(' ') ||
                  val.trim().length < 4) {
                return 'Username should not contain spaces and be less than 4 chars long';
              }
              return null;
            },
            onSaved: onSaved,
          );
  }
}