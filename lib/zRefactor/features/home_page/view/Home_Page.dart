import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/zRefactor/features/home_page/view/widgets/menu/menu.dart';
import 'package:chatoid/zRefactor/features/messages/model/clsMessage.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_state.dart';
import 'package:chatoid/zRefactor/features/home_page/view/widgets/home_view.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  // Declare ChatsCubit
  late ChatsCubit chatsCubit;

  // Declare StoryProvider
  late StoryProvider storyProvider;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access ChatsCubit and StoryProvider from the context
    chatsCubit = context.read<ChatsCubit>();
    storyProvider = context.read<StoryProvider>();
  }

  Future<void> _loadUserData() async {
    final loginCubit = context.read<LoginCubit>();
    await loginCubit.loadUserData();

    final currentUser = loginCubit.currentUser;

    // Fetch friends and messages from Supabase using ChatsCubit
    await chatsCubit.fetchFriends(currentUser.user_id);
    await chatsCubit.fetchAllMessages(currentUser);
    List<clsMessage> shroidaEGTMessages = chatsCubit.friendMessages
        .where((msg) =>
            msg.friendId == 6 && msg.senderId == 7 ||
            msg.friendId == 7 && msg.senderId == 6)
        .toList();
    for (var message in shroidaEGTMessages) {
      print("message replis shroida ${message.messsagReply}");
    }

    // Subscribe to real-time updates for messages and friends
    await chatsCubit.subscribe(
      'messages',
      () async {
        if (mounted) {
          await chatsCubit.fetchAllMessages(currentUser);
        }
      },
    );

    await chatsCubit.subscribe(
      'stories',
      () async {
        if (mounted) {
          await storyProvider.fetchAllStories();
        }
      },
    );

    await chatsCubit.subscribe(
      'friendships',
      () async {
        if (mounted) {
          await chatsCubit.fetchFriends(currentUser.user_id);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.watch<LoginCubit>();
    final themeCubit = context.watch<ThemeCubit>();

    final currentUser = loginCubit.currentUser;

    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        return ZoomDrawer(
          controller: _drawerController,
          menuScreen: MenuScreen(profileData: currentUser),
          mainScreen: HomeView(drawerController: _drawerController),
          angle: -15,
          duration:
              const Duration(milliseconds: 600), // Smooth transition duration
          slideWidth: MediaQuery.of(context).size.width * 0.65,
          borderRadius: 30.0, // Round edges of drawer
          menuBackgroundColor: themeCubit
              .colorOfApp, // Blue background between drawer and content
          mainScreenOverlayColor: themeCubit.colorOfApp
              .withOpacity(0.2), // Overlay when drawer is open
          showShadow: true, // 3D effect
          shadowLayer2Color: Colors.black.withOpacity(0.3), // Custom shadow
          shadowLayer1Color:
              Colors.black.withOpacity(0.1), // More subtle shadows
        );
      },
    );
  }
}
