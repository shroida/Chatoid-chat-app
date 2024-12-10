import 'package:chatoid/cubits/chatCubit/chat_cubit.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/zRefactor/features/register/view_model/signUp/signup_cubit.dart';
import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/data/provider/chat_provider.dart';
import 'package:chatoid/data/provider/notificaitionsprovider.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/firebase_options.dart';
import 'package:chatoid/zRefactor/core/utlis/app_router.dart';
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
    anonKey: my_Supa_key,
    debug: true,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (context) => LoginCubit(),
        ),
        BlocProvider<SignupCubit>(
          create: (context) => SignupCubit(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(), // Provide ChatCubit at a high level
        ),
      ],
      child: MultiProvider(
        providers: [
          
          ChangeNotifierProvider<ChatProvider>(
            create: (context) {
              final loginCubit = context.read<LoginCubit>();
              return ChatProvider(loginCubit: loginCubit);
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
       
       
       
        // theme: ThemeData.dark().copyWith(
        // scaffoldBackgroundColor: kPrimaryColor,
        // textTheme:
        //     GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
        // ),
      ),
    );
  }
}
