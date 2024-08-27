import 'package:flutter/material.dart';

class AuthFormActionButton extends StatelessWidget {
  final void Function() onPressed;
  final String title;
  const AuthFormActionButton({required this.onPressed, required this.title, super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ElevatedButton(
                  
                  style: ElevatedButton.styleFrom(
                    elevation: 2,

                    backgroundColor: Colors.white,//const Color.fromARGB(255, 203, 215, 247),
                    //backgroundColor: const Color.fromARGB(255, 226, 233, 247)//Theme.of(context).colorScheme.primaryContainer,
                  ),
                  onPressed: onPressed,
                  child: Text(title),
                  );
  }
}