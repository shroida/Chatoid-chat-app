import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';

class TapBarItem extends StatelessWidget {
  const TapBarItem({
    super.key,
    required this.onItemTapped,
    required this.label,
    required this.index,
    required this.currentIndex,
  });

  final ValueChanged<int> onItemTapped;
  final String label;
  final int index;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final themeCubit = BlocProvider.of<ThemeCubit>(context, listen: true);

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.07;

    return GestureDetector(
      onTap: () => onItemTapped(index), // Fixed callback execution
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: horizontalPadding,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: currentIndex == index
              ? themeCubit.colorOfApp
              : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: currentIndex == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
