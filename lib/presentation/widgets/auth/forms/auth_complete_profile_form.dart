import 'dart:io';

import 'package:chat_app/bloc/auth/auth_cubit.dart';
import 'package:chat_app/data/repository/auth_repo.dart';
import 'package:chat_app/data/repository/avatars_repo.dart';
import 'package:chat_app/data/repository/notifications_repo.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_action_button.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_email_field.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_misc_button.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_pwd_field.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_title.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_type.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_username_field.dart';
import 'package:chat_app/presentation/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:sign_in_button/sign_in_button.dart';

class AuthCompleteProfileForm extends StatefulWidget {
  final void Function(AuthFormType formType) switchFormTo;
  const AuthCompleteProfileForm({required this.switchFormTo, super.key});

  @override
  State<AuthCompleteProfileForm> createState() => _AuthCompleteProfileFormState();
}

class _AuthCompleteProfileFormState extends State<AuthCompleteProfileForm> {
  final _formState = GlobalKey<FormState>();
  String _enteredUsername = '';
  File? _pickedImage;
  void _submit() async {
    if (!_formState.currentState!.validate()) {
      return;
    }

    if (_pickedImage == null) { return; }

    //final avaUpload = await context.read<AvatarsRepo>().uploadAvatar(img: _pickedImage!);
    final registered = await context.read<AuthCubit>().tryCompleteRegisterAndSignIn(_enteredUsername);
    if (registered) {
      await context.read<AvatarsRepo>().updateAvatar(img: _pickedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formState,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AuthFormTitle(title: 'Complete profile'),
          UserImagePicker(
            onPickImage: (img) {
              _pickedImage = img;
            }
          ),
          const SizedBox(height: 20,),
          AuthFormUsernameField(onSaved: (val){
            if (val != null) {
              _enteredUsername = val;
            }
          }),
          const SizedBox(
            height: 40,
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: 
            [
              AuthFormMiscButton(
                onPressed: () async {
                  _formState.currentState!.reset();

                  await context.read<AuthCubit>().signOut();
                }, 
                title: 'Cancel'
              ),
              SizedBox(width: 80),
              AuthFormActionButton(
                onPressed: (){
                  _formState.currentState!.save();
                  _submit();
                },
                title: 'Finish'
              ),
              
            ],
          ),
        ],
      ),
    );
  }
}
