import 'package:chat_app/bloc/auth/auth_cubit.dart';
import 'package:chat_app/bloc/auth/auth_state.dart';
import 'package:chat_app/bloc/chat/chat_cubit.dart';
import 'package:chat_app/bloc/contacts/contacts_cubit.dart';
import 'package:chat_app/data/repository/auth_repo.dart';
import 'package:chat_app/data/repository/avatars_repo.dart';
import 'package:chat_app/data/repository/chats_cache_repo.dart';
import 'package:chat_app/data/repository/chats_repo.dart';
import 'package:chat_app/data/repository/notifications_repo.dart';
import 'package:chat_app/presentation/screens/auth_screen.dart';
import 'package:chat_app/presentation/screens/contacts_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'firebase_options.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(storageDirectory: await getApplicationDocumentsDirectory());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.signOut();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepo()),
        RepositoryProvider(create: (context) => AvatarsRepo()),
        RepositoryProvider(create: (context) => ChatsRepo()),
        RepositoryProvider(create: (context) => ChatsCacheRepo()),
        RepositoryProvider(create: (context) => NotificationsRepo()),
      ],
      child: Builder(builder: (context) {
        return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) {
                return AuthCubit(authRepo: context.read<AuthRepo>(), chatsCacheRepo: context.read<ChatsCacheRepo>(), notificationsRepo: context.read<NotificationsRepo>());
              }),
              BlocProvider(create: (context) {
                return ContactsCubit(authRepo: context.read<AuthRepo>());
              }),
              BlocProvider(create: (context) {
                return ChatCubit(chatsCacheRepo: context.read<ChatsCacheRepo>(), chatsRepo: context.read<ChatsRepo>(), authRepo: context.read<AuthRepo>());
              })
            ],
            child: Builder(builder: (context) {
              return MaterialApp(
                title: 'FlutterChat',
                theme: ThemeData().copyWith(
                  colorScheme: ColorScheme.fromSeed(
                      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
                      seedColor: const Color.fromARGB(255, 63, 17, 177)),
                ),
                home: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state.status == AuthStatus.SignedIn) {
                      return ContactsScreen();
                    }

                    return AuthScreen();
                  },
                ),
              );
            }));
      }),
    );
  }
}
