import 'package:chat_app/bloc/auth/auth_cubit.dart';
import 'package:chat_app/data/repository/auth_repo.dart';
import 'package:chat_app/data/repository/notifications_repo.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_action_button.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_email_field.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_misc_button.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_pwd_field.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_title.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:sign_in_button/sign_in_button.dart';

class AuthSignInForm extends StatefulWidget {
  final void Function(AuthFormType formType) switchFormTo;
  const AuthSignInForm({required this.switchFormTo, super.key});

  @override
  State<AuthSignInForm> createState() => _AuthSignInFormState();
}

class _AuthSignInFormState extends State<AuthSignInForm> {
  final _formState = GlobalKey<FormState>();
  String _enteredEmail = '';
  String _enteredPwd = '';

  void _submit() async {
    _formState.currentState!.save();

    if (!_formState.currentState!.validate()) {
      return;
    }

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
          const AuthFormTitle(title: 'Sign In'),
          AuthFormEmailField(onSaved: (val) {
            if (val != null) {
              _enteredEmail = val;
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
                title: 'Sign In'
              ),
                  //SizedBox(width: 64,),
              Container(margin: EdgeInsets.symmetric(horizontal: 16), child: Text(' or ', style: TextStyle(color: Colors.black.withOpacity(0.5)),)),
              Container(
                width: 174,
                child: SignInButton(
                  Buttons.google, onPressed: () async {
                    await _trySignInWithGoogle();
                  }
                ),
              ),
            ],
          ),
          SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuthFormMiscButton(
                onPressed: () {
                  _formState.currentState!.reset();
                  widget.switchFormTo(AuthFormType.SignUp);
                },
                title: 'Dont have an account?',

              ),
            ],
          ),
          

        ],
      ),
    );
  }
}
