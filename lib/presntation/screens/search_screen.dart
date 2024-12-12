import 'package:chatoid/zRefactor/features/home_page/view/widgets/Appbar/Search_widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final BuildContext parentContext;

  const SearchScreen({Key? key, required this.parentContext}) : super(key: key);

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
          child: Text('Open Search'),
        ),
      ),
    );
  }
}
