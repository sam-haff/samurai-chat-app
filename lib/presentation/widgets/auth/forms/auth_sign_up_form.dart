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

class AuthSignUpForm extends StatefulWidget {
  final void Function(AuthFormType formType) switchFormTo;
  const AuthSignUpForm({required this.switchFormTo, super.key});

  @override
  State<AuthSignUpForm> createState() => _AuthSignUpFormState();
}

class _AuthSignUpFormState extends State<AuthSignUpForm> {
  final _formState = GlobalKey<FormState>();

  File? _pickedImage;
  String _enteredEmail = '';
  String _enteredUsername = '';
  String _enteredPwd = '';

  void _submit() async {
    _formState.currentState!.save();

    if (!_formState.currentState!.validate()) {
      return;
    }
    context 
      .read<AuthCubit>()
      .trySignUp(
          email: _enteredEmail,
          username: _enteredUsername,
          pwd: _enteredPwd)
      .then( (success) {
        print("Okay, registation finishes with " + success.toString());
        if (success) {
          print("Now try sign in");
          var avatarsRepo = context.read<AvatarsRepo>();
          context.read<AuthCubit>().trySignIn(
            _enteredEmail,
            _enteredPwd,
            newOnSignIn: (ChatUser u) async {
              print("UPDATING AVATAR");
              print("Img " + _pickedImage.toString());
              print("Img " + _pickedImage!.path);
              //var avatarsRepo = context.read<AvatarsRepo>();
              //await context.read<AvatarsRepo>().updateAvatar(img: _pickedImage!);
              await avatarsRepo.updateAvatar(img: _pickedImage!);
            }
          );
        }

      }
    );

    await context.read<AuthCubit>().trySignIn(_enteredEmail, _enteredPwd);
  }

  Future<void> _trySignInWithGoogle() async {
    await context.read<AuthCubit>().trySignInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formState,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AuthFormTitle(title: 'Sign Up'),
          UserImagePicker(
            onPickImage: (img) {
              _pickedImage = img;
            }
          ),
          AuthFormEmailField(onSaved: (val) {
            if (val != null) {
              _enteredEmail = val;
            }
          }),
          AuthFormUsernameField(onSaved: (val) {
            if (val != null) {
              _enteredUsername = val;
            }
          }),
          AuthFormPwdField(onSaved: (val){
            if (val != null) {
              _enteredPwd = val;
            }
          }),
          
          SizedBox(
            height: 40,
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: 
            [
              AuthFormActionButton(
                onPressed: (){
                  _submit();
                },
                title: 'Sign Up'
              ),
                  //SizedBox(width: 64,),
            ],
          ),
          SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuthFormMiscButton(
                onPressed: () {
                  _formState.currentState!.reset();
                  widget.switchFormTo(AuthFormType.SignIn);
                },
                title: 'I have an account',

              ),
            ],
          ),
          

        ],
      ),
    );
  }
}
