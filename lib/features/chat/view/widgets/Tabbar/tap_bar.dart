import 'package:chatoid/features/chat/view/widgets/Tabbar/tap_bar_item.dart';
import 'package:flutter/material.dart';

class TapBar extends StatelessWidget {
  const TapBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(29.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TapBarItem(
            currentIndex: currentIndex,
            index: 0,
            label: "Messages",
            onItemTapped: onItemTapped,
          ),
          TapBarItem(
            currentIndex: currentIndex,
            index: 1,
            label: "Groups",
            onItemTapped: onItemTapped,
          ),
          TapBarItem(
            currentIndex: currentIndex,
            index: 2,
            label: "Themes",
            onItemTapped: onItemTapped,
          ),
        ],
      ),
    );
  }
}
