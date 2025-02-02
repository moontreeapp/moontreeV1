import 'package:flutter/material.dart';
import 'package:magic/presentation/utils/animation.dart';

class RotationAnimation extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final bool reverse;
  const RotationAnimation({
    super.key,
    required this.child,
    this.duration,
    this.reverse = false,
  });

  @override
  RotationAnimationState createState() => RotationAnimationState();
}

class RotationAnimationState extends State<RotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? fadeDuration * 5,
    );
    final Animation<double> curveAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInExpo);

    _rotationAnimation = Tween(begin: 0.0, end: .5).animate(curveAnimation);
    if (widget.reverse) {
      _controller.reverse(from: 1.0);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //void _startRotationAnimation() {
  //  if (_controller.isAnimating) {
  //    _controller.stop();
  //  }
  //  _controller.reset();
  //  _controller.forward();
  //}

  @override
  Widget build(BuildContext context) =>
      //_startRotationAnimation();
      RotationTransition(
        turns: _rotationAnimation,
        child: widget.child,
      );
}
