import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class LoginAnimationWidget extends StatefulWidget {
  final void Function(RiveAnimationController<dynamic>) addAnimationAction;

  const LoginAnimationWidget({
    super.key,
    required this.addAnimationAction,
  });

  @override
  LoginAnimationWidgetState createState() => LoginAnimationWidgetState();
}

class LoginAnimationWidgetState extends State<LoginAnimationWidget> {
  Artboard? riveArtboard;
  late RiveAnimationController controllerIdle;
  late RiveAnimationController controllerHandsUp;
  late RiveAnimationController controllerHandsDown;
  late RiveAnimationController controllerSuccess;
  late RiveAnimationController controllerFail;
  late RiveAnimationController controllerLookDownRight;
  late RiveAnimationController controllerLookDownLeft;

  @override
  void initState() {
    super.initState();
    controllerIdle = SimpleAnimation('idle');
    controllerHandsUp = SimpleAnimation('hands_up');
    controllerHandsDown = SimpleAnimation('hands_down');
    controllerSuccess = SimpleAnimation('success');
    controllerFail = SimpleAnimation('fail');
    controllerLookDownRight = SimpleAnimation('look_down_right');
    controllerLookDownLeft = SimpleAnimation('look_down_left');

    rootBundle.load('assets/animated_login.riv').then((data) async {
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      artboard.addController(controllerIdle); // Default animation
      setState(() {
        riveArtboard = artboard;
      });
    });
  }

  void setAnimation(RiveAnimationController controller) {
    widget.addAnimationAction(controller);
    riveArtboard?.artboard.removeController(controllerIdle);
    riveArtboard?.artboard.removeController(controllerHandsUp);
    riveArtboard?.artboard.removeController(controllerHandsDown);
    riveArtboard?.artboard.removeController(controllerSuccess);
    riveArtboard?.artboard.removeController(controllerFail);
    riveArtboard?.artboard.removeController(controllerLookDownRight);
    riveArtboard?.artboard.removeController(controllerLookDownLeft);
    riveArtboard?.addController(controller);
  }

  @override
  Widget build(BuildContext context) {
    return riveArtboard == null
        ? const CircularProgressIndicator()
        : SizedBox(
            height: 300, // Set an explicit height
            child: Rive(artboard: riveArtboard!),
          );
  }
}
