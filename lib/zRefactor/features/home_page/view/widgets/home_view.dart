
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/data/provider/chat_provider.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/presntation/screens/HomePageScreens/homePageChats.dart';
import 'package:chatoid/presntation/screens/HomePageScreens/homePageStoryPosts.dart';
import 'package:chatoid/presntation/screens/profile.dart';
import 'package:chatoid/presntation/screens/search_screen.dart';
import 'package:chatoid/presntation/widgets/Search_widget.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  final ZoomDrawerController drawerController;

  const HomeView({super.key, required this.drawerController});

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
    } else if (_currentIndex == 3) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.watch<LoginCubit>();
    final themeCubit = context.watch<ThemeCubit>();

    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                widget.drawerController.isOpen!()
                    ? widget.drawerController.close!()
                    : widget.drawerController.open!();
              },
            ),
            title: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Hello\n',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                    text: loginCubit.currentUser.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 26.0),
                child: IconButton(
                  icon: const Icon(Icons.search, size: 30),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(parentContext: context),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 26.0),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, size: 30),
                  onPressed: () {
                    _showThemeOptions(context, themeCubit);
                  },
                ),
              ),
            ],
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

Widget _buildthemeOptions(BuildContext context, ThemeCubit themeProvider) {
  List<Color> colors = [
    const Color.fromARGB(0, 96, 76, 212),
    ChatAppColors.primaryColor,
    ChatAppColors.primaryColor2,
    ChatAppColors.primaryColor3,
    ChatAppColors.primaryColor4,
    ChatAppColors.primaryColor5,
    ChatAppColors.primaryColor6,
    ChatAppColors.primaryColor7,
    ChatAppColors.primaryColor8,
  ];

  return Center(
    child: CarouselSlider(
      items: colors.map((color) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const SizedBox(height: 20),
        );
      }).toList(),
      options: CarouselOptions(
        height: 20,
        onPageChanged: (index, reason) {
          themeProvider.toggleBackground(index);
          themeProvider.saveColorOfApp(colors[index]);
        },
        enableInfiniteScroll: false,
        initialPage: 0,
      ),
    ),
  );
}

void _showThemeOptions(BuildContext context, ThemeCubit themeCubit) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Wrap(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 30, bottom: 30),
                      child: const Text(
                        'Interface Theme',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    ListTile(
                      title: const Text("Light Mode"),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: themeCubit.themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeCubit.toggleLightMode();
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text("Dark Mode"),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: themeCubit.themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeCubit.toggleDarkMode();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Container(
                  margin: const EdgeInsets.only(left: 30, bottom: 20),
                  child: const Text(
                    'Theme Color',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, bottom: 30),
                  child: const Text(
                    'Customize your application color',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ),
                _buildthemeOptions(context, themeCubit)
              ],
            ),
          ),
        ],
      );
    },
  );
}
