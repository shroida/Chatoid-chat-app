import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/zRefactor/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/zRefactor/features/chat/view/widgets/Messages%20Section/messages_section.dart';
import 'package:chatoid/zRefactor/features/chat/view/widgets/Tabbar/tap_bar.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageChats extends StatefulWidget {
  const HomePageChats({super.key});

  @override
  HomePageChatsState createState() => HomePageChatsState();
}

class HomePageChatsState extends State<HomePageChats> {
  int _currentIndexHomePage = 0;
  void _onTapBarItemTapped(int index) {
    setState(() {
      _currentIndexHomePage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = BlocProvider.of<ThemeCubit>(context, listen: true);

    return Scaffold(
      body: Column(
        children: [
          TapBar(
            currentIndex: _currentIndexHomePage,
            onItemTapped: _onTapBarItemTapped,
          ),
          Expanded(
            child: _currentIndexHomePage == 0
                ? const MessagesSection()
                : _currentIndexHomePage == 1
                    ? _buildGroupsSection()
                    : _buildSettingsSection(context, themeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsSection() {
    final chatsCubit = BlocProvider.of<ChatsCubit>(context, listen: true);

    return Text(
        'We will add this feature soon! ${chatsCubit.friendMessages.length }');
  }

  Widget _buildSettingsSection(BuildContext context, ThemeCubit themeProvider) {
    List<Color> colors = [
      const Color.fromARGB(0, 96, 76, 212),
      ChatAppColors.primaryColor,
      ChatAppColors.primaryColor2,
      ChatAppColors.primaryColor3,
      ChatAppColors.primaryColor4,
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
          height: 300,
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
}
