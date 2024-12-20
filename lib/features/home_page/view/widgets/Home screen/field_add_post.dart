import 'package:chatoid/core/utlis/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FieldAddPost extends StatelessWidget {
  const FieldAddPost({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push(AppRouter.kAddPost);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 50),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0), // Border line
            borderRadius: BorderRadius.circular(50), // Border radius
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(
                vertical: 20.0, horizontal: 70), // Padding inside the box
            child: Column(
              children: [
                Text(
                  'Add post ......',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
