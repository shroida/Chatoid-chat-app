import 'package:chatoid/zRefactor/core/utlis/themeCubit/theme_cubit.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomCurvedNavigation extends StatelessWidget {
  const BottomCurvedNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  final int currentIndex;
  final ValueChanged<int> onItemTapped; // Updated callback

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();

    return CurvedNavigationBar(
      index: currentIndex,
      color: themeCubit.colorOfApp,
      backgroundColor: Colors.transparent,
      items: [
        Icon(
          Icons.home,
          size: 30,
          color: currentIndex == 0 ? Colors.white : Colors.black,
        ),
        Icon(
          Icons.search,
          size: 30,
          color: currentIndex == 1 ? Colors.white : Colors.black,
        ),
        Icon(
          Icons.message_rounded,
          size: 30,
          color: currentIndex == 2 ? Colors.white : Colors.black,
        ),
        Icon(
          Icons.person,
          size: 30,
          color: currentIndex == 3 ? Colors.white : Colors.black,
        ),
      ],
      onTap: onItemTapped, // Use the callback with index
    );
  }
}
