import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildThemeOptions extends StatelessWidget {
  const BuildThemeOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();

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
