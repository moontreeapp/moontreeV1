import 'package:flutter/material.dart';
import 'package:moontree/presentation/theme/colors.dart';

class FadeHighlight extends StatefulWidget {
  final Widget child;
  final void Function()? onEnd;
  final Color? color;
  final Color? background;
  final Duration? delay;
  final Duration? duration;
  FadeHighlight({
    Key? key,
    required this.child,
    this.onEnd,
    this.color,
    this.background,
    this.delay,
    this.duration,
  }) : super(key: key);

  @override
  FadeHighlightState createState() => FadeHighlightState();
}

class FadeHighlightState extends State<FadeHighlight> {
  bool highlight = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay ?? const Duration(seconds: 2), unhighlight);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void unhighlight() {
    if (mounted) {
      setState(() => highlight = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
      onEnd: widget.onEnd,
      duration: widget.duration ?? const Duration(seconds: 4),
      color: highlight
          ? widget.color ?? AppColors.primary50
          : widget.background ?? Colors.white,
      child: widget.child);
}

class FlashHighlight extends StatefulWidget {
  final Widget child;
  final void Function()? onEnd;
  final Color? color;
  final Color? background;
  final Duration? delay;
  final Duration? duration;
  final Duration? fadeInDuration;
  final Duration? fadeOutDuration;
  FlashHighlight({
    Key? key,
    required this.child,
    this.onEnd,
    this.color,
    this.background,
    this.delay,
    this.duration,
    this.fadeInDuration,
    this.fadeOutDuration,
  }) : super(key: key);

  @override
  _FlashHighlightState createState() => _FlashHighlightState();
}

class _FlashHighlightState extends State<FlashHighlight> {
  bool? show;
  Duration? duration;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        widget.delay ?? const Duration(milliseconds: 250), highlight);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onEnd() {
    if (show == true) {
      Future.delayed(
        widget.duration ?? const Duration(seconds: 1),
        unhighlight,
      );
      return;
    }
    if (show == false) {
      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    }
  }

  void unhighlight() {
    if (mounted) {
      setState(() {
        show = false;
        duration = widget.fadeOutDuration;
      });
    }
  }

  void highlight() {
    if (mounted) {
      setState(() {
        show = true;
        duration = widget.fadeInDuration ?? const Duration(milliseconds: 750);
      });
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
      onEnd: onEnd,
      duration: duration ?? const Duration(seconds: 2),
      color: show ?? false
          ? widget.color ?? AppColors.secondary
          : widget.background ?? Colors.white,
      child: widget.child);
}
