import 'package:chat_app/bloc/auth/auth_cubit.dart';
import 'package:chat_app/bloc/contacts/contacts_cubit.dart';
import 'package:chat_app/bloc/contacts/contacts_state.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/presentation/screens/chat_screen.dart';
import 'package:chat_app/presentation/widgets/add_contact_button.dart';
import 'package:chat_app/presentation/widgets/fade_in_circular_avatar.dart';
import 'package:chat_app/presentation/widgets/new_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as Math;

import 'package:page_transition/page_transition.dart';

class ContactsScreen extends StatefulWidget {
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {

  void _openNewContact() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(child: NewContact(),);
      });
  }
  Route _createChatRoute(ChatUser contact) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 700),
      pageBuilder: (ctx, anim, secAnim){
        return ChatScreen(withContact: contact);
      },
      transitionsBuilder: (ctx, anim, secAnim, child) {
        final begin = Offset(1.0, 0.0);
        final end = Offset.zero;
        final curve = Curves.easeOutExpo;


        var tween = Tween(begin: begin, end: end).animate(CurvedAnimation(parent: anim, curve: curve));//Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(position: /*anim.drive(tween)*/tween, child: child);
      }
    );
  }
  void _openChatWith(ChatUser contact) {
    Navigator.of(context).push(_createChatRoute(contact));
    //Navigator.of(context).push(PageTransition(child: ChatScreen(withContact: contact), type: PageTransitionType.rightToLeft, curve: Curves.elasticIn, duration: Duration(milliseconds: 600)));
    //Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>ChatScreen(withContact: contact,)));
  }
  @override
  Widget build(BuildContext context) {
  // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.white,
        elevation: 1,
        forceMaterialTransparency: false,
        scrolledUnderElevation: 0.0,
        titleSpacing: 1,
        centerTitle: true,
        title: Text('Contacts', style: TextStyle(),),
        leading: IconButton(
                  onPressed: () {
                    context.read<AuthCubit>().signOut();
                  },
                  icon: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(Math.pi),
                    child: Icon(
                      Icons.exit_to_app,
                      color: const Color.fromARGB(255, 218, 86, 76),
                    ),
                  )) ,
        actions: [
          TextButton(
            child: Container(
              margin: EdgeInsets.only(right: 0),
              child: AddContactButton(onPress: _openNewContact),
            ),
            onPressed: null,
          ),
        ],
      ),
      body: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, state) {
          if (state.contacts.isNotEmpty){
            final contactsList = state.contacts.entries.toList();
            return Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: contactsList.length,
                      itemBuilder: (ctx, idx) {
                        int borderBlackness = 0;
                        BorderSide borderSide = BorderSide(color: Color.fromARGB(69, borderBlackness, borderBlackness, borderBlackness), width: 0.5);
                        Border border = Border(top: idx == 0 ? borderSide : BorderSide.none, bottom: borderSide);
                        return Container(
                          padding: EdgeInsets.all(0),
                          child: InkWell(
                            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                            onTap: () { _openChatWith(contactsList[idx].value); },
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(height: 2,),
                                      FadeInCircularAvatar(url: contactsList[idx].value.imgUrl, radius: 30,),
                                      SizedBox(height: 2,),
                                    ],
                                  ),
                                  SizedBox(width: 15,),
                                  Expanded(
                                    child: Container(
                                      height: double.infinity,
                                      decoration: BoxDecoration(border: border),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        contactsList[idx].value.username, 
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ); 
                        /*ListTile(
                          //tileColor: const Color.fromARGB(255, 234, 234, 234),
                          leading: FadeInCircularAvatar(url: contactsList[idx].value.imgUrl),
                          title: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  width: 200,
                                  decoration: BoxDecoration(border: border),
                                  child: Text(contactsList[idx].value.username)
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            onPressed:(){ 
                              _openChatWith(contactsList[idx].value);
                            }, 
                            icon: Icon(Icons.message, color: Theme.of(context).colorScheme.primary.withOpacity(0.8),)
                          ),
                          /*shape: Border(
                            top: BorderSide(color: const Color.fromARGB(69, 0, 0, 0)),
                            bottom: BorderSide(color: Color.fromARGB(idx == contactsList.length-1 ? 69 : 9, 0, 0, 0)),
                          ) */
                        );*/
                      }
                    ),
                  )
                ],
              ),
            );
          } else {
            return Center(child: Text('No contacts yet'));
          }
        }
        )
      );
        
  }
}
