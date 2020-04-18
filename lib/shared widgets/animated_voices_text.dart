import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
import 'package:voices/constants.dart';

class VoicesAnimated extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<VoicesAnimated> with SingleTickerProviderStateMixin {

  // Animation related fields.
  AnimationController controller;
  SequenceAnimation sequenceAnimation;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return new AnimatedBuilder(
      builder: (context, child) {
        return new Center(
          child: new Text(
              "VOICES",
              style: TextStyle(
                color: sequenceAnimation["color"].value,
                fontSize: 100.0,
              )
          ),
        );
      },
      animation: controller,
    );
  }


  @override
  void initState() {
    super.initState();

    controller = new AnimationController(vsync: this);
    
    sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
        animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
        from:  const Duration(microseconds: 0),
        to: const Duration(milliseconds: animationspeed),
        tag: "color"
    ).addAnimatable(
        animatable: new ColorTween(begin: Colors.yellow, end: Colors.blueAccent),
        from:  const Duration(milliseconds: animationspeed),
        to: const Duration(milliseconds: animationspeed * 2),
        tag: "color",
        curve: Curves.easeOut
    ).addAnimatable(
        animatable: new ColorTween(begin: Colors.blueAccent, end: Colors.pink),
        //  animatable: new Tween<double>(begin: 200.0, end: 40.0),
        from:  const Duration(milliseconds: animationspeed * 2),
        to: const Duration(milliseconds: animationspeed * 3),
        tag: "color",
        curve: Curves.fastOutSlowIn
    ).animate(controller);

    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }

      print(status);
    });
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
        animation: controller,
        builder: _buildAnimation);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
