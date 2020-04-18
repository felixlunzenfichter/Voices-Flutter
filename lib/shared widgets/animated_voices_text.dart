import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';

class VoicesAnimated extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<VoicesAnimated> with SingleTickerProviderStateMixin {

  // Animation related fields.
  AnimationController controller;
  SequenceAnimation sequenceAnimation;

  // TODO: is busy loop
  Future<Null> _playAnimation() async {
    try {
      while (true) {
        await controller.forward().orCancel;
        await controller.reverse().orCancel;
      }
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

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
    // TODO: implement initState
    super.initState();

    controller = new AnimationController(vsync: this);
    
    sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
        animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
        from:  const Duration(seconds: 0),
        to: const Duration(seconds: 2),
        tag: "color"
    ).addAnimatable(
        animatable: new ColorTween(begin: Colors.yellow, end: Colors.blueAccent),
        from:  const Duration(seconds: 2),
        to: const Duration(seconds: 4),
        tag: "color",
        curve: Curves.easeOut
    ).addAnimatable(
        animatable: new ColorTween(begin: Colors.blueAccent, end: Colors.pink),
        //  animatable: new Tween<double>(begin: 200.0, end: 40.0),
        from:  const Duration(seconds: 5),
        to: const Duration(seconds: 6),
        tag: "color",
        curve: Curves.fastOutSlowIn
    ).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    _playAnimation();

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
