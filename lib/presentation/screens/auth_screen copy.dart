import 'dart:io';

import 'package:chat_app/bloc/auth/auth_cubit.dart';
import 'package:chat_app/bloc/auth/auth_state.dart';
import 'package:chat_app/data/repository/auth_repo.dart';
import 'package:chat_app/data/repository/avatars_repo.dart';
import 'package:chat_app/data/repository/notifications_repo.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/presentation/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  var _isSignIn = true;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPwd = '';

  @override
  void dispose() {
    super.dispose();
  }

  void _uiCommunicateException(String? msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg ?? 'Auth failed')));
  }

  Future<void> _trySignIn(void Function(ChatUser)? onSignIn) async {
    await context.read<AuthCubit>().trySignIn(_enteredEmail, _enteredPwd, newOnSignIn: onSignIn);

    final token = await context.read<NotificationsRepo>().setupPushNotifications();
    if (token != null) {
      final deviceId = await FlutterUdid.udid;
      await context.read<AuthRepo>().registerToken(deviceName: deviceId!, token: token!);
    } else {
    }
  } 

  Future<void> _trySignInWithGoogle() async {
    await context.read<AuthCubit>().trySignInWithGoogle();

    final token = await context.read<NotificationsRepo>().setupPushNotifications();
    if (token != null) {
      final deviceId = await FlutterUdid.udid;
      await context.read<AuthRepo>().registerToken(deviceName: deviceId!, token: token!);
    } else {
      print('-----No token');
    }
  } 

  Future<void> _tryCompleteRegister(void Function(ChatUser)? onSignIn) async {
    await context.read<AuthCubit>().tryCompleteRegisterAndSignIn(_enteredUsername);
    
    final token = await context.read<NotificationsRepo>().setupPushNotifications();
    if (token != null) {
      final deviceId = await FlutterUdid.udid;
      await context.read<AuthRepo>().registerToken(deviceName: deviceId!, token: token!);
    } else {
      print('-----No token');
    } 
  }

  void _submit(BuildContext ctx) async {
    if (!_formState.currentState!.validate()) {
      return;
    }
    if (!_isSignIn && _pickedImage == null) {
      return;
    }

    _formState.currentState!.save();

    if (ctx.read<AuthCubit>().state.status == AuthStatus.NeedsCompleteProfile){
      final registered = await context.read<AuthCubit>().tryCompleteRegisterAndSignIn(_enteredUsername);
      if (registered) {
        await ctx.read<AvatarsRepo>().updateAvatar(img: _pickedImage!);
      }

      return;
    }
    if (_isSignIn) {
      await _trySignIn(null);
    } else {
      ctx
          .read<AuthCubit>()
          .trySignUp(
              email: _enteredEmail,
              username: _enteredUsername,
              pwd: _enteredPwd)
          .then( (success) {
            if (success) {
              _trySignIn(
                (ChatUser u) async {
                  await ctx.read<AvatarsRepo>().updateAvatar(img: _pickedImage!);
                }
              );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    var _netInAuthProcess = authState.status == AuthStatus.SingingIn ||
        authState.status == AuthStatus.SingingOn;

    bool usernameFieldVisible = !_isSignIn || authState.status == AuthStatus.NeedsCompleteProfile;
    bool pwdFieldVisible = authState.status != AuthStatus.NeedsCompleteProfile;
    bool emailFieldVisible = pwdFieldVisible;
    bool avaPickerVisible = usernameFieldVisible;

    String title = _isSignIn ? 'Sign in' : 'Sign up';
    if (authState.status == AuthStatus.NeedsCompleteProfile){
      title = 'Complete profile';
    }

    // TODO: implement build
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
                    elevation: 20,
                    child: AnimatedSize(
                      duration: Duration(milliseconds: 1500),
                      curve: Curves.easeOutExpo,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formState,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(bottom: 48),
                                child: Text(title, style: TextStyle(fontSize: 22),)
                              ),
                              if (avaPickerVisible)
                                UserImagePicker(onPickImage: (img) {
                                  _pickedImage = img;
                                }),
                              if (emailFieldVisible)
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'email',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  validator: (val) {
                                    if (val == null ||
                                        val.trim().isEmpty ||
                                        !val.trim().contains('@')) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                  onSaved: (val) {
                                    _enteredEmail = val!;
                                  },
                                ),
                              if (usernameFieldVisible)
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'username',
                                  ),
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  validator: (val) {
                                    if (val == null ||
                                        val.trim().isEmpty ||
                                        val.trim().contains(' ') ||
                                        val.trim().length < 4) {
                                      return 'Username should not contain spaces and be less than 4 chars long';
                                    }
                                    return null;
                                  },
                                  onSaved: (val) {
                                    if (val != null) {
                                      _enteredUsername = val;
                                    }
                                  },
                                ),
                              if (pwdFieldVisible)
                                TextFormField(
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
                                  onSaved: (val) {
                                    _enteredPwd = val!;
                                  },
                                ),
                              SizedBox(
                                height: 40,
                              ),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: authState.status == AuthStatus.NeedsCompleteProfile ?
                                [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                      onPressed: () {
                                        _submit(context);
                                      },
                                      child: Text('Finish'),
                                      ),
                  
                                ]:
                                [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                      onPressed: () {
                                        _submit(context);
                                      },
                                      child: _netInAuthProcess
                                          ? CircularProgressIndicator()
                                          : Text(_isSignIn ? 'Sign In' : 'Sign Up')
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
                                  if (authState.status != AuthStatus.NeedsCompleteProfile)
                                  TextButton(
                                    onPressed: 
                                    () {
                                          _formState.currentState!.reset();
                                          setState(() {
                                            _isSignIn = !_isSignIn;
                                          });
                                    },
                                    child: Text(
                                      _isSignIn ? "I don't have an account" : 'I have an account',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5)
                                      ),
                                    ),
                                  ),
                                                                  /*Checkbox(
                                      value: _isSignIn,
                                      onChanged: (val) {
                                        if (val != null) {
                                          _formState.currentState!.reset();
                                          setState(() {
                                            _isSignIn = val;
                                          });
                                        }
                                      }),
                                  Text('I have an account')*/
                                ],
                              ),
                              
                  
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
