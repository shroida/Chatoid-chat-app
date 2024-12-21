import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SmoothIndicatorProfile extends StatelessWidget {
  const SmoothIndicatorProfile({super.key, required this.controller});
  final PageController controller;
  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: 3,
      effect: WormEffect(
        activeDotColor: Colors.blue,
        dotColor: Colors.white.withOpacity(0.5),
        dotHeight: 10,
        dotWidth: 100,
        spacing: 8.0,
      ),
    );
  }
}
