import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

class RiveAnimationManager {
  rive.Artboard? riveArtboard;
  late rive.RiveAnimationController controllerIdle;
  late rive.RiveAnimationController controllerHandsUp;
  late rive.RiveAnimationController controllerHandsDown;
  late rive.RiveAnimationController controllersuccess;
  late rive.RiveAnimationController controllerFail;
  late rive.RiveAnimationController controllerLookDownRight;
  late rive.RiveAnimationController controllerLookDownLeft;

  RiveAnimationManager() {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    controllerIdle = rive.SimpleAnimation('idle');
    controllerHandsUp = rive.SimpleAnimation('Hands_up');
    controllerHandsDown = rive.SimpleAnimation('hands_down');
    controllersuccess = rive.SimpleAnimation('success');
    controllerFail = rive.SimpleAnimation('fail');
    controllerLookDownRight = rive.SimpleAnimation('Look_down_right');
    controllerLookDownLeft = rive.SimpleAnimation('Look_down_left');
  }

  Future<void> loadArtboard(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final file = rive.RiveFile.import(data);
      final artboard = file.mainArtboard;
      artboard.addController(controllerIdle);
      riveArtboard = artboard;
    } catch (e) {
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
          GlobalKey<ScaffoldMessengerState>();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('There is an issue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void addAnimation(rive.RiveAnimationController controller) {
    if (riveArtboard != null) {
      _removeAllControllers();
      riveArtboard!.addController(controller);
    }
  }

  void _removeAllControllers() {
    if (riveArtboard != null) {
      riveArtboard!.removeController(controllerIdle);
      riveArtboard!.removeController(controllerHandsUp);
      riveArtboard!.removeController(controllerHandsDown);
      riveArtboard!.removeController(controllersuccess);
      riveArtboard!.removeController(controllerFail);
      riveArtboard!.removeController(controllerLookDownRight);
      riveArtboard!.removeController(controllerLookDownLeft);
    }
  }

  void resetToIdle() {
    _removeAllControllers();
    if (riveArtboard != null) {
      riveArtboard!.addController(controllerIdle);
    }
  }
}
