import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/zRefactor/features/messages/view_model/messagesCubit/messages_cubit.dart';
import 'package:chatoid/zRefactor/features/profile/view_model/cubit/profile_cubit.dart';
import 'package:chatoid/zRefactor/features/register/view_model/signUp/signup_cubit.dart';
import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/data/provider/chat_provider.dart';
import 'package:chatoid/data/provider/notificaitionsprovider.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/firebase_options.dart';
import 'package:chatoid/zRefactor/core/utlis/app_router.dart';
import 'package:chatoid/zRefactor/features/story/view_model/cubit/story_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize('e1416184-6af7-4fcc-8603-72e042e1718d');
  OneSignal.Notifications.requestPermission(true);

  await Supabase.initialize(
    url: urlSupa,
    anonKey: mySupakey,
    debug: true,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(),
        ),
        BlocProvider<SignupCubit>(
          create: (context) => SignupCubit(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<ChatsCubit>(
          create: (context) => ChatsCubit(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(),
        ),
        BlocProvider<StoryCubit>(
          create: (context) => StoryCubit(),
        ),
        BlocProvider<MessagesCubit>(
          create: (context) {
            final authProvider = BlocProvider.of<LoginCubit>(context);
            final chatsCubit = BlocProvider.of<ChatsCubit>(context);
            return MessagesCubit(
                authProvider: authProvider, chatsCubit: chatsCubit);
          },
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ChatProvider>(
            create: (context) {
              final loginCubit = context.read<LoginCubit>();
              final chatsCubit = context.read<ChatsCubit>();
              return ChatProvider(
                chatsCubit: chatsCubit,
                loginCubit: loginCubit,
              );
            },
          ),
          ChangeNotifierProvider<NotificationProvider>(
            create: (context) {
              final chatProvider = Provider.of<ChatProvider>(context);
              // final chatCubit = context.read<ChatCubit>();

              return NotificationProvider(chatProvider);
            },
          ),
          ChangeNotifierProvider<StoryProvider>(
            create: (context) {
              return StoryProvider();
            },
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,

      // theme: ThemeData.dark().copyWith(
      // scaffoldBackgroundColor: kPrimaryColor,
      // textTheme:
      //     GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
      // ),
    );
  }
}
