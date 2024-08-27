import 'dart:io';

import 'package:chat_app/bloc/auth/auth_cubit.dart';
import 'package:chat_app/bloc/auth/auth_state.dart';
import 'package:chat_app/data/repository/auth_repo.dart';
import 'package:chat_app/data/repository/avatars_repo.dart';
import 'package:chat_app/data/repository/notifications_repo.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/presentation/widgets/auth/auth_form_type.dart';
import 'package:chat_app/presentation/widgets/auth/forms/auth_complete_profile_form.dart';
import 'package:chat_app/presentation/widgets/auth/forms/auth_sign_in_form.dart';
import 'package:chat_app/presentation/widgets/auth/forms/auth_sign_up_form.dart';
import 'package:chat_app/presentation/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _formState = GlobalKey<FormState>();

  File? _pickedImage;

  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPwd = '';

  AuthFormType _formType = AuthFormType.SignIn;

  @override
  void dispose() {
    super.dispose();
  }

  void _uiCommunicateException(String? msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg ?? 'Auth failed')));
  }

  void _switchFormTo(AuthFormType form){
    setState(() {
      _formType = form;
    });
  }

  Widget _currentForm() {
    switch (_formType) {
      case AuthFormType.SignIn: {
        return AuthSignInForm(switchFormTo: _switchFormTo);
      }
      case AuthFormType.SignUp: {
        return AuthSignUpForm(switchFormTo: _switchFormTo);
      }
      case AuthFormType.CompleteProfile: {
        print('returning complete profile form');
        return AuthCompleteProfileForm(switchFormTo: _switchFormTo);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    print('Auth State Status');
    print(authState.status.name);

    var _netInAuthProcess = authState.status == AuthStatus.SingingIn ||
        authState.status == AuthStatus.SingingOn;

    if (authState.status == AuthStatus.NeedsCompleteProfile) {
      _formType = AuthFormType.CompleteProfile;
    } else {
      if (_formType == AuthFormType.CompleteProfile && !_netInAuthProcess) {
        _formType = AuthFormType.SignIn;
      }
    }

    print(_formType.name);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.errorStatus != null) {
          _uiCommunicateException(state.errorStatus!.msg + state.status.name);
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 215, 222, 240),
        body: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                width: 400,
                margin: EdgeInsets.all(24),
                child: Image.asset('assets/images/chat.png'),
              ),
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(8),
                  child: Card(
                    color: const Color.fromARGB(225, 255, 255, 255),
                    elevation: 20,
                    child: AnimatedSize(
                      duration: Duration(milliseconds: 1500),
                      curve: Curves.easeOutExpo,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _currentForm(),
                      ),
                    ),
                  ).animate(effects: [SlideEffect(begin: Offset(0, -0.25), curve: Curves.easeOutExpo, duration: Duration(milliseconds: 1500)), FadeEffect(duration: Duration(milliseconds: 1200))]),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
