import 'package:flutter/material.dart';

class ShakeTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShakeTransition({Key? key, required this.child, this.duration = const Duration(milliseconds: 300)}) : super(key: key);

  @override
  ShakeTransitionState createState() => ShakeTransitionState();
}

class ShakeTransitionState extends State<ShakeTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.1, 0.0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);
  }

  void shake() {
    _controller.forward(from: 0).then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
