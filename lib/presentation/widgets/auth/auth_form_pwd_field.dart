import 'package:flutter/material.dart';

class AuthFormPwdField extends StatelessWidget {
  final Function(String? val) onSaved;
  const AuthFormPwdField({required this.onSaved, super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextFormField(
            decoration: const InputDecoration(
              labelText: 'password',
            ),
            obscureText: true,
            validator: (val) {
              if (val == null ||
                  val.isEmpty ||
                  val.contains(' ') ||
                  val.length < 6) {
                return 'Password should be at least 6 chars long and not contain white spaces';
              }

              return null;
            },
            onSaved: onSaved,
          );
  }
}