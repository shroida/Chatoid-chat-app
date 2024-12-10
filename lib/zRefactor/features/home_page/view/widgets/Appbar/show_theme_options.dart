import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/zRefactor/features/home_page/view/widgets/Appbar/build_theme_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShowThemeOptions extends StatelessWidget {
  const ShowThemeOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();

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
              const BuildThemeOptions(),
            ],
          ),
        ),
      ],
    );
  }
}
