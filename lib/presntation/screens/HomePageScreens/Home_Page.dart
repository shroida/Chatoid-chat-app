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
import 'package:chatoid/presntation/screens/menu.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();
  late ChatProvider chatProvider; // Declare ChatProvider here
  late StoryProvider storyProvider; // Declare ChatProvider here
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

    // Check if currentUser is null before using it
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
    // Add your refresh logic here.
    // You may want to call relevant fetch functions for each screen.
    if (_currentIndex == 0) {
      // Refresh HomePageStoryPosts
      final storyProvider = context.read<StoryProvider>();
      await storyProvider.fetchAllStories();
    } else if (_currentIndex == 1) {
      // Refresh SearchScreen if needed
    } else if (_currentIndex == 2) {
      // Refresh HomePageChats
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.fetchAllMessages(currentUser);
    } else if (_currentIndex == 3) {
      // Refresh Profile if needed
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 30, bottom: 30),
                      child: Text(
                        'Interface Theme',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    ListTile(
                      title: Text("Light Mode"),
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
                      title: Text("Dark Mode"),
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
                SizedBox(height: 60),
                Container(
                  margin: EdgeInsets.only(left: 30, bottom: 20),
                  child: Text(
                    'Theme Color',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 30, bottom: 30),
                  child: Text(
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
