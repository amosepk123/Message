import 'dart:async';

import 'package:flutter/material.dart';

import 'Wrapper.dart';


class splash_screen extends StatefulWidget {
  splash_screen({Key? key}) : super(key: key);

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start the animation
    _controller.forward();

    // Navigate to home page after 6 seconds
    Timer(Duration(seconds: 50), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Wrapper()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   "picture/splash2.gif",
              //   height: 150,
              //   width: 150,
              //   fit: BoxFit.fill,
              // ),
              //
              // Image.asset(
              //   "picture/splashGif.gif",
              //   height: 170,
              //   width: 170,
              //   fit: BoxFit.fill,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}