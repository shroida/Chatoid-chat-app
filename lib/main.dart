import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/messages/view_model/messagesCubit/messages_cubit.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_cubit.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/profile/view_model/cubit/profile_cubit.dart';
import 'package:chatoid/features/register/view_model/signUp/signup_cubit.dart';
import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/firebase_options.dart';
import 'package:chatoid/core/utlis/app_router.dart';
import 'package:chatoid/features/story/view_model/cubit/story_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(oneSignal);
  OneSignal.Notifications.requestPermission(true);

  await Supabase.initialize(
    url: urlSupa,
    anonKey: mySupakey,
    debug: true,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<StoryCubit>(
          create: (context) => StoryCubit(),
        ),
        BlocProvider<PostsCubit>(
          create: (context) => PostsCubit(),
        ),
        BlocProvider<ChatsCubit>(
          create: (context) => ChatsCubit(),
        ),
        BlocProvider(
          create: (context) => LoginCubit(
            context.read<ChatsCubit>(),
            context.read<PostsCubit>(),
            context.read<StoryCubit>(),
          ),
        ),
        BlocProvider<SignupCubit>(
          create: (context) => SignupCubit(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(),
        ),
        BlocProvider<MessagesCubit>(
          create: (context) {
            final authProvider = BlocProvider.of<LoginCubit>(context);
            final chatsCubit = BlocProvider.of<ChatsCubit>(context);

            return MessagesCubit(
                loginCubit: authProvider, chatsCubit: chatsCubit);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return MaterialApp.router(
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          theme: theme, // Use the theme from the ThemeCubit
        );
      },
    );
  }
}
