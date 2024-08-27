import 'package:flutter/material.dart';

class AuthFormTitle extends StatelessWidget {
  final String title;
  const AuthFormTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(bottom: 48),
            child: Text(title, style: TextStyle(fontSize: 22),)
          );
  }
}