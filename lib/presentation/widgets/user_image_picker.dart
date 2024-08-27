import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File) onPickImage;

  const UserImagePicker({required this.onPickImage, super.key});
  @override
  State<StatefulWidget> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void _ioPickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    
    if (f != null) {
      setState(() {
        _pickedImage = File(f.path);
      });
    }

    widget.onPickImage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedImage == null ? null : FileImage(_pickedImage!),
        ),
        SizedBox(height: 8,),
        TextButton.icon(
          onPressed: _ioPickImage,
          icon: Icon(Icons.image),
          label: Text('Pick image'),
        )
      ],
    );
  }
}