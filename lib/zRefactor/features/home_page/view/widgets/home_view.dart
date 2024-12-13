import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/zRefactor/features/chat/view/home_page_chats.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/zRefactor/features/home_page/view/widgets/Home%20screen/home_screen_story_posts.dart';
import 'package:chatoid/zRefactor/features/profile/view/profile.dart';
import 'package:chatoid/presntation/screens/search_screen.dart';
import 'package:chatoid/zRefactor/features/home_page/view/widgets/Appbar/app_bar_home_view.dart';
import 'package:chatoid/zRefactor/features/home_page/view/widgets/Bottom%20Navigation/bottom_curved_navigation.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.drawerController});
  final ZoomDrawerController drawerController;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late UserData currentUser;
  List<Widget>? screens;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    final loginCubit = BlocProvider.of<LoginCubit>(context);
    currentUser = loginCubit.currentUser;

    _loadThemePreference();
    context.read<ThemeCubit>().loadThemeMode();

    screens = [
      const HomeScreenStoryPosts(),
      SearchScreen(parentContext: context),
      const HomePageChats(),
      Profile(userProfile: currentUser),
    ];

  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _refreshData() async {
    if (_currentIndex == 0) {
      // Refresh HomePageStoryPosts
      final storyProvider = context.read<StoryProvider>();
      await storyProvider.fetchAllStories();
    } else if (_currentIndex == 1) {
    } else if (_currentIndex == 2) {
      final chatsCubit = context.read<ChatsCubit>();
      await chatsCubit.fetchAllMessages(currentUser);
    } else if (_currentIndex == 3) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBarHomeView(
              drawerController: widget.drawerController,
            ),
            body: screens != null
                ? RefreshIndicator(
                    onRefresh: _refreshData,
                    child: IndexedStack(
                      index: _currentIndex,
                      children: screens!,
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
            bottomNavigationBar: BottomCurvedNavigation(
              currentIndex: _currentIndex,
              onItemTapped: _onItemTapped,
            ));
      },
    );
  }
}
