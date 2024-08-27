import 'package:flutter/material.dart';

class AuthFormEmailField extends StatelessWidget {
  final Function(String? val) onSaved;
  const AuthFormEmailField({required this.onSaved, super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextFormField(
            decoration: InputDecoration(
              labelText: 'email',
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            validator: (val) {
              if (val == null ||
                  val.trim().isEmpty ||
                  !val.trim().contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onSaved: onSaved,
          );
  }
}