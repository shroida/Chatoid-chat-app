import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class BearAnimation extends StatelessWidget {
  const BearAnimation({super.key, this.riveArtboard});
  final rive.Artboard? riveArtboard;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: riveArtboard == null
          ? const CircularProgressIndicator()
          : SizedBox(
              width: double.infinity,
              height: 300,
              child: rive.Rive(artboard: riveArtboard!),
            ),
    );
  }
}
