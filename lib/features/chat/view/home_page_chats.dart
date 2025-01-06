import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/features/chat/view/widgets/Messages%20Section/messages_section.dart';
import 'package:chatoid/features/chat/view/widgets/Tabbar/tap_bar.dart';
import 'package:chatoid/features/chat/view/widgets/Group%20Section/group_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageChats extends StatefulWidget {
  const HomePageChats({super.key});

  @override
  HomePageChatsState createState() => HomePageChatsState();
}

class HomePageChatsState extends State<HomePageChats> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();

    return Scaffold(
      body: Column(
        children: [
          TapBar(
            currentIndex: _currentIndex,
            onItemTapped: (index) => setState(() => _currentIndex = index),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                const MessagesSection(),
                const GroupSection(),
                _buildThemeSection(context, themeCubit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeCubit themeCubit) {
    final colors = [
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
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }).toList(),
        options: CarouselOptions(
          height: 300,
          onPageChanged: (index, reason) {
            themeCubit.toggleBackground(index);
            themeCubit.saveColorOfApp(colors[index]);
          },
          enableInfiniteScroll: false,
          initialPage: 0,
        ),
      ),
    );
  }
}