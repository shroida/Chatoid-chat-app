import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/presntation/widgets/Search_widget.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class AppBarHomeView extends StatefulWidget implements PreferredSizeWidget {
  const AppBarHomeView({super.key, required this.drawerController});
  final ZoomDrawerController drawerController;

  @override
  State<AppBarHomeView> createState() => _AppBarHomeViewState();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarHomeViewState extends State<AppBarHomeView> {
  @override
  Widget build(BuildContext context) {
    final loginCubit = context.watch<LoginCubit>();
    final themeCubit = context.watch<ThemeCubit>();
    return AppBar(
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
