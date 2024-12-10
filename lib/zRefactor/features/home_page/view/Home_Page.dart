import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/data/provider/chat_provider.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/zRefactor/features/home_page/view/widgets/home_view.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:chatoid/presntation/screens/menu.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();
  late ChatProvider chatProvider;
  late StoryProvider storyProvider;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chatProvider =
        Provider.of<ChatProvider>(context); // G// Get provider reference here
    storyProvider =
        Provider.of<StoryProvider>(context); // G// Get provider reference here
  }

  Future<void> _loadUserData() async {
    final loginCubit = context.read<LoginCubit>();
    await loginCubit.loadUserData();

    final currentUser = loginCubit.currentUser;

    // Fetch friends and messages from Supabase on every navigation to HomePage
    await chatProvider.fetchFriends(currentUser.user_id);
    await chatProvider.fetchAllMessages(currentUser);

    // Subscribe to real-time updates for messages and friends
    await chatProvider.subscribe(
      'messages',
      () async {
        if (mounted) {
          await chatProvider.fetchAllMessages(currentUser);
        }
      },
    );
    await chatProvider.subscribe(
      'stories',
      () async {
        if (mounted) {
          await storyProvider.fetchAllStories();
        }
      },
    );
    await chatProvider.subscribe(
      'friendships',
      () async {
        if (mounted) {
          await chatProvider.fetchFriends(currentUser.user_id);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.watch<LoginCubit>();
    final themeCubit = context.watch<ThemeCubit>();

    final currentUser = loginCubit.currentUser;
    return ZoomDrawer(
      controller: _drawerController,
      menuScreen: MenuScreen(profileData: currentUser),
      mainScreen: HomeView(drawerController: _drawerController),
      angle: -15,
      duration: const Duration(milliseconds: 600), // Smooth transition duration
      slideWidth: MediaQuery.of(context).size.width * 0.65,
      borderRadius: 30.0, // Round edges of drawer
      menuBackgroundColor: themeCubit
          .colorOfApp, // Background between drawer and content is blue
      mainScreenOverlayColor: themeCubit.colorOfApp
          .withOpacity(0.2), // Blue overlay when the drawer is open
      showShadow: true, // Show shadow for a 3D effect
      shadowLayer2Color:
          Colors.black.withOpacity(0.3), // Layer shadow customization
      shadowLayer1Color: Colors.black.withOpacity(0.1), // More subtle shadows
    );
  }
}
