import 'package:flutter/material.dart';

import 'donePage.dart';


class AnimatedCounterPage extends StatefulWidget {
  final int countTo;
  final double fontSize;
  final VoidCallback? theEnimationEnded;

  const AnimatedCounterPage({
    Key? key,
    required this.countTo,
    required this.fontSize,
    this.theEnimationEnded,
  }) : super(key: key);

  @override
  _AnimatedCounterPageState createState() => _AnimatedCounterPageState();
}

class _AnimatedCounterPageState extends State<AnimatedCounterPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Adjust the duration as needed
    );

    _animation = IntTween(begin: 1, end: widget.countTo).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation has completed, invoke the callback
        widget.theEnimationEnded?.call();

      }
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Text(
            _animation.value.toString(),
            style: TextStyle(fontSize: widget.fontSize),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
