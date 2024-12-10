import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/data/provider/chat_provider.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/presntation/screens/HomePageScreens/homePageChats.dart';
import 'package:chatoid/presntation/screens/HomePageScreens/homePageStoryPosts.dart';
import 'package:chatoid/presntation/screens/profile.dart';
import 'package:chatoid/presntation/screens/search_screen.dart';
import 'package:chatoid/zRefactor/features/home_page/view/widgets/app_bar_home_view.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
      const HomePageStoryPosts(),
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
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.fetchAllMessages(currentUser);
    } else if (_currentIndex == 3) {}
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();

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
          bottomNavigationBar: CurvedNavigationBar(
            index: _currentIndex,
            color: themeCubit.colorOfApp,
            backgroundColor: Colors.transparent,
            items: [
              Icon(
                Icons.home,
                size: 30,
                color: _currentIndex == 0 ? Colors.white : Colors.black,
              ),
              Icon(
                Icons.search,
                size: 30,
                color: _currentIndex == 1 ? Colors.white : Colors.black,
              ),
              Icon(
                Icons.message_rounded,
                size: 30,
                color: _currentIndex == 2 ? Colors.white : Colors.black,
              ),
              Icon(
                Icons.person,
                size: 30,
                color: _currentIndex == 3 ? Colors.white : Colors.black,
              ),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
