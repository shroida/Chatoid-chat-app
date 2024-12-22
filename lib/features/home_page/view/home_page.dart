import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/features/home_page/view/widgets/menu/menu.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/home_page/view/widgets/home_view.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_cubit.dart';
import 'package:chatoid/features/story/view_model/cubit/story_cubit.dart';
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
  late PostsCubit postsCubit;

  // Declare sotryCubit
  late StoryCubit sotryCubit;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access ChatsCubit and sotryCubit from the context
    chatsCubit = context.read<ChatsCubit>();
    postsCubit = context.read<PostsCubit>();
    sotryCubit = context.read<StoryCubit>();
  }

  Future<void> _loadUserData() async {
    final loginCubit = context.read<LoginCubit>();
    await loginCubit.loadUserData();

    final currentUser = loginCubit.currentUser;

    // Fetch friends and messages from Supabase using ChatsCubit
    await chatsCubit.fetchFriends(currentUser.userId);
    await chatsCubit.fetchAllMessages(currentUser);
    await chatsCubit.fetchAllMessagesInGroupForAllUsers();
    await chatsCubit.fetchAllUsersGroup();
    await postsCubit.getAllPosts();
    await chatsCubit.subscribe(
      'messages',
      () async {
        if (mounted) {
          await chatsCubit.fetchAllMessages(currentUser);
        }
      },
    );
    await chatsCubit.subscribe(
      'posts',
      () async {
        if (mounted) {
          await postsCubit.getAllPosts();
        }
      },
    );
    await chatsCubit.subscribe(
      'all_messages_group',
      () async {
        if (mounted) {
          await chatsCubit.fetchAllMessagesInGroupForAllUsers();
        }
      },
    );

    await chatsCubit.subscribe(
      'stories',
      () async {
        if (mounted) {
          await sotryCubit.fetchAllStories(); // Ensure this updates the state
        }
      },
    );

    await chatsCubit.subscribe(
      'friendships',
      () async {
        if (mounted) {
          await chatsCubit.fetchFriends(currentUser.userId);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginCubit = BlocProvider.of<LoginCubit>(context);
    final themeCubit = context.watch<ThemeCubit>();

    final currentUser = loginCubit.currentUser;

    return ZoomDrawer(
      controller: _drawerController,
      menuScreen: MenuScreen(profileData: currentUser),
      mainScreen:
          HomeView(drawerController: _drawerController, themeCubit: themeCubit),
      angle: -15,
      duration: const Duration(milliseconds: 600), // Smooth transition duration
      slideWidth: MediaQuery.of(context).size.width * 0.65,
      borderRadius: 30.0, // Round edges of drawer
      menuBackgroundColor:
          themeCubit.colorOfApp, // Blue background between drawer and content
      mainScreenOverlayColor:
          themeCubit.colorOfApp.withOpacity(0.2), // Overlay when drawer is open
      showShadow: true, // 3D effect
      shadowLayer2Color: Colors.black.withOpacity(0.3), // Custom shadow
      shadowLayer1Color: Colors.black.withOpacity(0.1), // More subtle shadows
    );
  }
}
