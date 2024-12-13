import 'package:chatoid/features/home_page/view/widgets/Appbar/search_widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final BuildContext parentContext;

  const SearchScreen({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showSearch(
              context: parentContext,
              delegate: CustomSearchDelegate(parentContext: parentContext),
            );
          },
          child: const Text('Open Search'),
        ),
      ),
    );
  }
}
