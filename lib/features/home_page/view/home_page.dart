import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/home_page/view/widgets/menu/menu.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/home_page/view/widgets/home_view.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_cubit.dart';
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
  late ChatsCubit chatsCubit;
  late PostsCubit postsCubit;
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chatsCubit = BlocProvider.of<ChatsCubit>(context);
    postsCubit = BlocProvider.of<PostsCubit>(context);
  }

  @override
  void dispose() {
    if (isSubscribed) {
      chatsCubit.unsubscribe();
    }
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final loginCubit = BlocProvider.of<LoginCubit>(context, listen: false);
    await loginCubit.loadUserData();
    final currentUser = loginCubit.currentUser;
    await chatsCubit.fetchFriends(currentUser.userId);
    await chatsCubit.fetchAllMessages(currentUser);

    await postsCubit.getAllPosts();

    isSubscribed = true;

    await chatsCubit.subscribe(
      'messages',
      () async {
        if (mounted) {
          await chatsCubit.fetchAllMessages(currentUser);
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

    return _buildZoomDrawer(currentUser, themeCubit);
  }

  Widget _buildZoomDrawer(UserData currentUser, ThemeCubit themeCubit) {
    return ZoomDrawer(
      controller: _drawerController,
      menuScreen: MenuScreen(profileData: currentUser),
      mainScreen:
          HomeView(drawerController: _drawerController, themeCubit: themeCubit),
      angle: -15,
      duration: const Duration(milliseconds: 600),
      slideWidth: MediaQuery.of(context).size.width * 0.65,
      borderRadius: 30.0,
      menuBackgroundColor: themeCubit.colorOfApp,
      mainScreenOverlayColor: themeCubit.colorOfApp.withOpacity(0.2),
      showShadow: true,
      shadowLayer2Color: Colors.black.withOpacity(0.3),
      shadowLayer1Color: Colors.black.withOpacity(0.1),
    );
  }
}
