import 'package:chatoid/presntation/widgets/Search_widget.dart';
import 'package:chatoid/zRefactor/features/home_page/view/widgets/show_theme_options.dart';
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
              _showThemeOptions(context);
            },
          ),
        ),
      ],
    );
  }
}

void _showThemeOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return const ShowThemeOptions();
    },
  );
}
