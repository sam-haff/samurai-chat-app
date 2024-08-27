import 'package:flutter/material.dart';

class AuthFormMiscButton extends StatelessWidget {
  final void Function() onPressed;
  final String title;
  const AuthFormMiscButton({required this.onPressed, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton(
                onPressed: onPressed,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  ),
                ),
              ) ;
  }
}