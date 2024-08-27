import 'package:flutter/material.dart';

class AddContactButton extends StatelessWidget {
  final void Function() onPress;

  const AddContactButton({required this.onPress, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPress, icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary,));
    return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onPress,
                      splashColor: Colors.blue.withOpacity(0.1),
                      child: Icon(Icons.add, size: 17, color: Theme.of(context).colorScheme.primary),
                    ),
                    color: Colors.transparent,
                  ),
                ),
              );
  }
}